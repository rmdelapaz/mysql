#!/usr/bin/env python3
"""Run every SQL lab file in the kit against a real MySQL server and report PASS/FAIL.

For each labs/module-NN/ folder (one folder per 3-hour session) this runs

  * every  *_starter.sql    (must run without an error exactly as handed out, TODOs and all),
  * every  *_solution.sql   (must run without an error and print its answers),
  * every  debug_*.sql      (a deliberately broken handout: it MUST fail, and only with the error
                             numbers its header declares, e.g.  -- expect-error: 1452, 1364),
  * every other *.sql with a state header (check_environment.sql and similar support scripts).

STARTING STATE. Every lab file declares, in a comment near the top, the database it starts from:

    -- state: full        the course database, labs/_states/bookstore.sql (Lesson 4.2 onward)
    -- state: flat        the Module 3 bookstore (books.author is text), labs/_states/flat.sql
    -- state: schema      the end of Lesson 2.1: three empty tables, labs/_states/schema.sql
    -- state: none        no bookstore at all (Module 1 and Lesson 2.1); the lab makes its own database

For flat / schema / full the checker loads that state into a SCRATCH database (kitlab_check by default),
never into your own `bookstore`, and runs the lab with the scratch database as the default database,
exactly as a learner runs it inside `bookstore`. To make that possible it rewrites the database NAME
(not the data) on the fly: `USE bookstore`, `CREATE/DROP DATABASE ... bookstore`, `bookstore.table`
and the string 'bookstore' (as in  WHERE table_schema = 'bookstore'). Labs should not need `USE` at all.
For state none the lab runs with no default database; it creates and drops its own (e.g. kit_s1_sheet).

HOW A FILE IS RUN. Through the real mysql command-line client, fed on standard input, with
    --table  (the boxed result tables learners see)   --commands  (client commands such as \\G work;
    MySQL 9.7 turns them off in batch mode; left out automatically for a MariaDB client)
    --show-warnings   and, for debug_*.sql only, --force (keep going after each error).
A file FAILS when the client exits non-zero (an SQL error), when a debug file raises no error or an
undeclared one, or runs past the timeout (default 60 s).

SAFETY. Before and after the run the checker lists the server's databases and accounts. A lab that
leaves behind a new database or a new account FAILS (and the checker drops what it left, since it did not
exist before). It also fails, without running it, any lab that would change the root account or the
server's settings: ALTER/DROP/RENAME USER on root or CURRENT_USER(), SET PASSWORD for root or yourself,
SET GLOBAL, SET PERSIST. The checker itself never changes root: it only creates and drops its scratch
database (and whatever the labs create and drop).

WHICH SERVER (first match wins)
  1. Environment variables (point it at YOUR server):
        MYSQL_LABS_CLIENT     the mysql client program (default: mysql on your PATH)
        MYSQL_LABS_HOST       e.g. 127.0.0.1   (default: localhost)
        MYSQL_LABS_PORT       e.g. 3306
        MYSQL_LABS_SOCKET     a socket file, instead of host/port
        MYSQL_LABS_USER       default root; any account that may create and drop databases and users
        MYSQL_LABS_PASSWORD   its password (written to a private temporary option file, never on the command line)
        MYSQL_LABS_SCRATCH    the scratch database name (default kitlab_check; it is DROPPED and re-created)
     Setting any MYSQL_LABS_* connection variable selects this mode.
  2. The course author's MySQL 9.7 test server (~/.cache/mysql-course), when it exists: started if
     needed, and run under the same lock file as the course tools, so no other run resets it meanwhile.
  3. Otherwise: mysql on your PATH, localhost, root, no password (you will probably need option 1).

Usage (from anywhere):
    python3 labs/check_labs.py                 # all sessions
    python3 labs/check_labs.py module-03       # one session (also 03 or 3; several allowed)
    python3 labs/check_labs.py module-03 -v    # also show each file's output (tail)
    python3 labs/check_labs.py --file labs/module-03/l2_3-crud/x_solution.sql -v    # one file
    python3 labs/check_labs.py --timeout 120 module-05
    python3 labs/check_labs.py --strict        # all sessions; a session with no labs is a failure
Exit code: 0 when everything passed, 1 otherwise. Standard library only; Python 3.8+.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import time
from contextlib import contextmanager
from pathlib import Path

LABS = Path(__file__).resolve().parent
KIT = LABS.parent
STATES = LABS / "_states"
STATE_FILES = {"full": "bookstore.sql", "flat": "flat.sql", "schema": "schema.sql"}
VALID_STATES = ("none", "schema", "flat", "full")
COURSE_CACHE = Path.home() / ".cache" / "mysql-course"
COURSE_BASE = COURSE_CACHE / "mysql-9.7.2-linux-glibc2.28-x86_64-minimal"
COURSE_SOCK = COURSE_CACHE / "mysql.sock"
COURSE_LOCK = COURSE_CACHE / "run_sql_blocks.lock"
COURSE_FILES = COURSE_CACHE / "files"
DEFAULT_TIMEOUT = 60
SYSTEM_DBS = {"mysql", "information_schema", "performance_schema", "sys"}
IGNORE_DIRS = {"_states", "_fixtures", "__pycache__", "output"}

STATE_RE = re.compile(r"(?im)^\s*--\s*state\s*:\s*([A-Za-z-]+)\s*$")
EXPECT_RE = re.compile(r"(?im)^\s*--\s*expect-error\s*:\s*([0-9 ,]+)\s*$")
ERROR_RE = re.compile(r"^ERROR (\d+) \(([0-9A-Z]+)\)", re.M)
WARN_RE = re.compile(r"^Warning \(Code (\d+)\): (.*)$", re.M)
FORBIDDEN = [
    (re.compile(r"(?is)\b(ALTER|DROP|RENAME)\s+USER\b[^;]*?['`\"]?\broot\b"), "changes the root account"),
    (re.compile(r"(?is)\bALTER\s+USER\s+(IF\s+EXISTS\s+)?CURRENT_USER\b"), "changes the account the checker runs as"),
    (re.compile(r"(?is)\bSET\s+PASSWORD\s*(=|FOR\s+(CURRENT_USER|['`\"]?root\b))"), "changes the root (or your own) password"),
    (re.compile(r"(?is)\bSET\s+(@@)?(GLOBAL|PERSIST|PERSIST_ONLY)\b"), "changes a server-wide setting (SET GLOBAL / SET PERSIST)"),
    (re.compile(r"(?im)^\s*(mysql|MariaDB \[[^\]]*\])>"), "contains a mysql> prompt (learners would copy it)"),
]


# ------------------------------------------------------------------------------------------- connection
class Server:
    def __init__(self, scratch: str):
        self.scratch = scratch
        self.mode = None
        self.env = dict(os.environ)
        self.tmp = Path(tempfile.mkdtemp(prefix="kitlabs_"))
        self.base: list[str] = []
        self.describe = ""
        names = ("MYSQL_LABS_CLIENT", "MYSQL_LABS_HOST", "MYSQL_LABS_PORT", "MYSQL_LABS_SOCKET",
                 "MYSQL_LABS_USER", "MYSQL_LABS_PASSWORD")
        if any(os.environ.get(n) for n in names):
            self._env_mode()
        elif (COURSE_BASE / "bin" / "mysql").is_file():
            self._course_mode()
        else:
            self._env_mode()
        self.is_mariadb = False

    def _env_mode(self):
        self.mode = "env"
        client = os.environ.get("MYSQL_LABS_CLIENT") or shutil.which("mysql") or shutil.which("mariadb")
        if not client:
            raise SystemExit("No mysql client found. Put mysql on your PATH or set MYSQL_LABS_CLIENT.")
        opt = self.tmp / "client.cnf"
        lines = ["[client]", f"user={os.environ.get('MYSQL_LABS_USER', 'root')}"]
        if os.environ.get("MYSQL_LABS_PASSWORD"):
            lines.append("password=" + os.environ["MYSQL_LABS_PASSWORD"])
        if os.environ.get("MYSQL_LABS_SOCKET"):
            lines.append("socket=" + os.environ["MYSQL_LABS_SOCKET"])
        else:
            lines.append("host=" + os.environ.get("MYSQL_LABS_HOST", "localhost"))
            if os.environ.get("MYSQL_LABS_PORT"):
                lines.append("port=" + os.environ["MYSQL_LABS_PORT"])
        opt.write_text("\n".join(lines) + "\n", encoding="utf-8")
        opt.chmod(stat.S_IRUSR | stat.S_IWUSR)
        self.base = [client, f"--defaults-file={opt}"]
        where = os.environ.get("MYSQL_LABS_SOCKET") or (os.environ.get("MYSQL_LABS_HOST", "localhost")
                                                         + (":" + os.environ["MYSQL_LABS_PORT"] if os.environ.get("MYSQL_LABS_PORT") else ""))
        self.describe = f"{os.environ.get('MYSQL_LABS_USER', 'root')}@{where} via {client}"

    def _course_mode(self):
        self.mode = "course"
        self.env["LD_LIBRARY_PATH"] = str(COURSE_CACHE / "libaio" / "usr" / "lib" / "x86_64-linux-gnu")
        ping = subprocess.run([str(COURSE_BASE / "bin" / "mysqladmin"), "--no-defaults", "-uroot", f"--socket={COURSE_SOCK}", "ping"],
                              capture_output=True, text=True, env=self.env)
        if ping.returncode != 0 and (COURSE_CACHE / "start.sh").is_file():
            subprocess.run(["bash", str(COURSE_CACHE / "start.sh")], capture_output=True, text=True)
        self.base = [str(COURSE_BASE / "bin" / "mysql"), "--no-defaults", f"--socket={COURSE_SOCK}", "-uroot"]
        self.describe = "the course's MySQL 9.7 test server (~/.cache/mysql-course)"

    def argv(self, database=None, table=True, force=False, commands=True):
        a = list(self.base) + ["--default-character-set=utf8mb4", "--local-infile=1", "--connect-timeout=10"]
        if table:
            a += ["--table", "--show-warnings"]
        if commands and not self.is_mariadb:
            a.append("--commands")
        if force:
            a.append("--force")
        if database:
            a += ["-D", database]
        return a

    def run(self, sql, database=None, force=False, timeout=DEFAULT_TIMEOUT, cwd=None, table=True):
        return subprocess.run(self.argv(database, table=table, force=force), input=sql, capture_output=True,
                              text=True, env=self.env, timeout=timeout, cwd=cwd)

    def rows(self, sql):
        a = list(self.base) + ["--default-character-set=utf8mb4", "--connect-timeout=10", "-N", "-B"]
        r = subprocess.run(a, input=sql, capture_output=True, text=True, env=self.env, timeout=60)
        if r.returncode != 0:
            raise RuntimeError(r.stderr.strip())
        return [ln.split("\t") for ln in r.stdout.splitlines()]

    def connect_check(self):
        try:
            v = self.rows("SELECT VERSION();")[0][0]
        except (RuntimeError, IndexError, subprocess.TimeoutExpired) as e:
            raise SystemExit(f"Cannot connect to {self.describe}:\n  {e}\n"
                             "Set MYSQL_LABS_HOST / MYSQL_LABS_PORT / MYSQL_LABS_USER / MYSQL_LABS_PASSWORD "
                             "(see the top of this file).")
        self.is_mariadb = "mariadb" in v.lower()
        if self.is_mariadb:
            # a MariaDB client does not know --commands
            pass
        else:
            probe = subprocess.run(list(self.base) + ["--commands", "-e", "SELECT 1"], capture_output=True, text=True, env=self.env)
            if probe.returncode != 0 and "unknown option" in probe.stderr.lower():
                self.is_mariadb = True        # old or MariaDB client: run without --commands
        return v

    def cleanup(self):
        shutil.rmtree(self.tmp, ignore_errors=True)


@contextmanager
def course_lock(server: Server):
    """The course tools reset the shared test server at the start of every run: wait for them, then hold them off."""
    if server.mode != "course":
        yield
        return
    import fcntl
    COURSE_LOCK.parent.mkdir(parents=True, exist_ok=True)
    with open(COURSE_LOCK, "w") as fh:
        try:
            fcntl.flock(fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print("[waiting for another run on the course test server to finish ...]", flush=True)
            fcntl.flock(fh, fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(fh, fcntl.LOCK_UN)


# ------------------------------------------------------------------------------------------- SQL rewriting
def rename_db(sql: str, scratch: str) -> str:
    """Point every reference to the `bookstore` DATABASE at the scratch database (data and other words untouched)."""
    sql = re.sub(r"(?i)\b(DATABASE|SCHEMA)(\s+IF\s+(?:NOT\s+)?EXISTS)?(\s+)`?bookstore`?(?![\w.])",
                 lambda m: f"{m.group(1)}{m.group(2) or ''}{m.group(3)}{scratch}", sql)
    sql = re.sub(r"(?im)^(\s*USE\s+)`?bookstore`?(\s*;)", lambda m: f"{m.group(1)}{scratch}{m.group(2)}", sql)
    sql = re.sub(r"(?<![@\w.`'])`?bookstore`?\.(?=`?[A-Za-z_])", scratch + ".", sql)
    sql = re.sub(r"'bookstore'", f"'{scratch}'", sql)
    return sql


def state_sql(state: str, scratch: str) -> str:
    path = STATES / STATE_FILES[state]
    if not path.is_file():
        raise FileNotFoundError(f"labs/_states/{STATE_FILES[state]} is missing (state '{state}')")
    return rename_db(path.read_text(encoding="utf-8"), scratch)


# ------------------------------------------------------------------------------------------- one file
def header(text: str):
    head = "\n".join(text.splitlines()[:25])
    m = STATE_RE.search(head)
    e = EXPECT_RE.search(head)
    codes = sorted({int(x) for x in re.findall(r"\d+", e.group(1))}) if e else []
    return (m.group(1).lower() if m else None), codes


def kind_of(path: Path) -> str:
    if path.name.startswith("debug_"):
        return "debug"
    if path.stem.endswith("_starter"):
        return "starter"
    if path.stem.endswith("_solution"):
        return "solution"
    return "support"


def snapshot(server: Server):
    dbs = {r[0] for r in server.rows("SHOW DATABASES;")}
    try:
        users = {(r[0], r[1]) for r in server.rows("SELECT User, Host FROM mysql.user;")}
    except RuntimeError:
        users = None
    try:
        root = server.rows("SELECT User, Host, plugin, authentication_string, account_locked FROM mysql.user WHERE User = 'root' ORDER BY Host;")
    except RuntimeError:
        root = None
    return dbs, users, root


def server_files():
    if not COURSE_FILES.is_dir():
        return set()
    return {p.name for p in COURSE_FILES.iterdir()}


def check_file(path: Path, server: Server, args, before) -> tuple[bool, str, str]:
    """(ok, one-line verdict, output) for one lab file."""
    text = path.read_text(encoding="utf-8")
    kind = kind_of(path)
    state, codes = header(text)
    problems = []
    if state is None:
        return False, "no '-- state: none|schema|flat|full' line in the first 25 lines", ""
    if state not in VALID_STATES:
        return False, f"unknown state '{state}' (use {', '.join(VALID_STATES)})", ""
    if kind == "debug" and not codes:
        return False, "a debug_*.sql handout needs an '-- expect-error: NNNN[, NNNN]' line in its header", ""
    if kind != "debug" and codes:
        problems.append("'-- expect-error' only belongs in debug_*.sql")
    for rx, why in FORBIDDEN:
        if rx.search(re.sub(r"(?m)--[^\n]*$", "", text) if "prompt" not in why else text):
            return False, f"not run: the file {why}", ""
    if kind == "starter" and "TODO" not in text:
        problems.append("WARN starter has no TODO")
    if re.search(r"(?im)^\s*USE\s+`?bookstore`?\s*;", text):
        problems.append("WARN contains USE bookstore (labs run inside the learner's current database; the checker rewrote it)")

    scratch = server.scratch
    db = None
    files_before = server_files() if server.mode == "course" else set()
    try:
        server.rows(f"DROP DATABASE IF EXISTS `{scratch}`;")
        if state != "none":
            r = server.run(state_sql(state, scratch), table=False, timeout=120)
            if r.returncode != 0:
                return False, f"could not load state '{state}': {r.stderr.strip()[:200]}", ""
            db = scratch
        sql = rename_db(text, scratch)
        t0 = time.perf_counter()
        r = server.run(sql, database=db, force=(kind == "debug"), timeout=args.timeout, cwd=str(path.parent))
        dt = time.perf_counter() - t0
    except subprocess.TimeoutExpired:
        return False, f"timed out after {args.timeout} s (a statement waiting for a lock, or a runaway query?)", ""
    except FileNotFoundError as e:
        return False, str(e), ""
    out = (r.stdout + ("\n" + r.stderr if r.stderr.strip() else "")).strip("\n")
    errs = [int(x) for x, _ in ERROR_RE.findall(r.stderr)]
    warns = WARN_RE.findall(r.stdout + r.stderr)
    ok = True
    if kind == "debug":
        if not errs:
            ok = False
            problems.append(f"expected error(s) {codes}, but the file ran cleanly")
        else:
            bad = sorted({e for e in errs if e not in codes})
            missing = [c for c in codes if c not in errs]
            if bad:
                ok = False
                problems.append(f"undeclared error(s) {bad} (declared {codes})")
            if missing:
                ok = False
                problems.append(f"declared error(s) {missing} never happened")
    elif r.returncode != 0 or errs:
        ok = False
        first = next((ln for ln in r.stderr.splitlines() if ln.startswith("ERROR")), r.stderr.strip()[:200])
        problems.append(first)
    if warns and kind != "debug":
        problems.append("WARN " + "; ".join(f"warning {c}: {m[:70]}" for c, m in warns[:3]))

    # leftovers: databases and accounts that did not exist before this file ran
    try:
        server.rows(f"DROP DATABASE IF EXISTS `{scratch}`;")
        dbs, users, root = snapshot(server)
        new_dbs = sorted(d for d in dbs - before[0] if d != scratch)
        if new_dbs:
            ok = False
            problems.append(f"left database(s) behind: {', '.join(new_dbs)} (end the lab with DROP DATABASE)")
            server.rows("".join(f"DROP DATABASE IF EXISTS `{d}`;" for d in new_dbs))
        if users is not None and before[1] is not None:
            new_users = sorted(users - before[1])
            if new_users:
                ok = False
                problems.append("left account(s) behind: " + ", ".join(f"'{u}'@'{h}'" for u, h in new_users)
                                + " (end the lab with DROP USER)")
                server.rows("".join(f"DROP USER IF EXISTS '{u}'@'{h}';" for u, h in new_users))
        if root is not None and before[2] is not None and root != before[2]:
            ok = False
            problems.append("the root account changed during this file")
            if server.mode == "course":
                server.rows("ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '';")
    except RuntimeError as e:
        problems.append(f"WARN could not list databases/accounts afterwards: {e}")
    if server.mode == "course":
        new_files = server_files() - files_before
        for name in new_files:
            try:
                (COURSE_FILES / name).unlink()
            except OSError:
                pass
        if new_files:
            problems.append("WARN wrote server file(s) " + ", ".join(sorted(new_files))
                            + " (removed; SELECT ... INTO OUTFILE refuses to overwrite on the next run)")
    verdict = f"{dt:5.1f}s" + (" · " + " · ".join(problems) if problems else "")
    return ok, verdict, out


# ------------------------------------------------------------------------------------------- driver
def lab_files(mod: Path):
    files = []
    for p in sorted(mod.rglob("*.sql")):
        if any(part in IGNORE_DIRS for part in p.relative_to(mod).parts):
            continue
        files.append(p)
    return files


def pairs_problems(files):
    have = {p for p in files}
    out = []
    for f in files:
        for a, b in (("_starter", "_solution"), ("_solution", "_starter")):
            if f.stem.endswith(a) and f.with_name(f.stem[: -len(a)] + b + ".sql") not in have:
                out.append(f"{f.name} has no partner {f.stem[: -len(a)] + b}.sql")
    return out


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Run every SQL lab file against MySQL and report PASS/FAIL.")
    ap.add_argument("sessions", nargs="*", help="module-03, 03 or 3 (default: all)")
    ap.add_argument("--file", action="append", default=[], help="check one file (repeatable)")
    ap.add_argument("-v", "--verbose", action="store_true")
    ap.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT)
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args(argv)

    mods = sorted(p for p in LABS.glob("module-*") if p.is_dir())
    if args.sessions:
        want = []
        for s in args.sessions:
            m = re.fullmatch(r"(?:module-)?(\d{1,2})", s)
            if not m:
                raise SystemExit(f"Not a session: {s!r} (use module-03, 03 or 3)")
            want.append(LABS / f"module-{int(m.group(1)):02d}")
        mods = want
    jobs = []
    failures = 0
    for f in args.file:
        p = Path(f).expanduser().resolve()
        if not p.is_file():
            raise SystemExit(f"no such file: {f}")
        jobs.append(p)
    if not args.file:
        for mod in mods:
            if not mod.is_dir():
                print(f"FAIL {mod.name}: folder does not exist")
                failures += 1
                continue
            files = lab_files(mod)
            if not files:
                msg = f"{mod.name}: no lab files"
                if args.sessions or args.strict:
                    print("FAIL " + msg)
                    failures += 1
                else:
                    print("skip " + msg)
            if not (mod / "README.md").is_file():
                print(f"FAIL {mod.name}: README.md is missing")
                failures += 1
            for msg in pairs_problems(files):
                print(f"FAIL {mod.name}: {msg}")
                failures += 1
            jobs += files
    if not jobs:
        print(f"\n0 files checked · {failures} failure(s)")
        return 1 if failures else 0

    server = Server(os.environ.get("MYSQL_LABS_SCRATCH", "kitlab_check"))
    passed = 0
    try:
        with course_lock(server):
            version = server.connect_check()
            print(f"Server: {version} · {server.describe} · scratch database `{server.scratch}`")
            if not version.startswith("9.7"):
                print("note: the labs and their expected outputs were made on MySQL 9.7; other versions may print different results.")
            before = snapshot(server)
            for p in jobs:
                rel = p.relative_to(KIT) if KIT in p.parents else p
                ok, verdict, out = check_file(p, server, args, before)
                print(f"{'PASS' if ok else 'FAIL'} {rel}  {verdict}")
                if args.verbose or (not ok and out):
                    tail = out.splitlines()[-40:] if not args.verbose else out.splitlines()[-80:]
                    for ln in tail:
                        print("      " + ln)
                passed += ok
                failures += not ok
            server.rows(f"DROP DATABASE IF EXISTS `{server.scratch}`;")
    finally:
        server.cleanup()
    print(f"\n{passed} passed, {failures} failed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
