#!/usr/bin/env bash
# check_environment.sh: macOS and Linux (also WSL and Git Bash).
# 1) checks that the mysql CLIENT is on your PATH and which version it is,
# 2) runs check_environment.sql on your SERVER: version, settings and the FULL bookstore (Part 2).
# Load the course database first (mysql> SOURCE bookstore.sql): Part 2 needs all 8 tables.
#
# Run it from the folder that holds labs/:
#   bash labs/module-08/l5_0-part2-start/check_environment.sh                    # asks for root's password
#   bash labs/module-08/l5_0-part2-start/check_environment.sh -h 127.0.0.1 -P 3306 -u root -p   # Docker, other port
# Arguments, when you give any, replace the default "-u root -p" and go to the mysql client unchanged.
# Docker without a client on your computer:
#   docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table' < labs/module-08/l5_0-part2-start/check_environment.sql

here="$(cd "$(dirname "$0")" && pwd)"

if ! command -v mysql >/dev/null 2>&1; then
  echo "NOT READY  the mysql client is not on your PATH (Lesson 1.2, Common Mistake 1)."
  echo "           macOS: add the export PATH line from Lesson 1.2 to ~/.zshrc and open a new Terminal."
  echo "           Docker: use the docker exec line at the top of this file."
  exit 1
fi

ver="$(mysql --version)"
echo "client     $ver"
num="$(printf '%s\n' "$ver" | sed -n 's/.*Ver \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2/p')"
read -r major minor <<<"$num"
case "$ver" in
  *MariaDB*) echo "CHECK      a MariaDB client: it connects to MySQL 9.7, but some client messages differ from the lessons" ;;
  *)
    if [ -z "$major" ]; then echo "CHECK      could not read the client version"
    elif [ "$major" -gt 9 ] || { [ "$major" -eq 9 ] && [ "$minor" -ge 7 ]; }; then echo "OK         mysql client $major.$minor (9.7 or newer)"
    elif [ "$major" -eq 8 ] && [ "$minor" -eq 4 ]; then echo "CHECK      mysql client 8.4: fine for the course; outputs match 9.7 almost everywhere"
    else echo "CHECK      mysql client $major.$minor is older than 8.4: install the 9.7 client (Lesson 1.2)"
    fi ;;
esac

if [ "$#" -eq 0 ]; then set -- -u root -p; fi
echo "server     connecting with: mysql $*"
if ! mysql "$@" --table < "$here/check_environment.sql"; then
  echo
  echo "NOT READY  the client could not finish (read the ERROR line above):"
  echo "           1045 = wrong user or password; 2002/2003 = the server is not running, or wrong host/port"
  echo "           (Lesson 1.2, Common Mistakes 2 and 3)."
  exit 1
fi
