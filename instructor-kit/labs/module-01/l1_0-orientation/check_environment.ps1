# check_environment.ps1: Windows PowerShell.
# 1) checks that the mysql CLIENT is on your PATH and which version it is,
# 2) runs check_environment.sql on your SERVER and prints its verdict.
#
# Run it from the folder that holds labs\ :
#   powershell -ExecutionPolicy Bypass -File labs\module-01\l1_0-orientation\check_environment.ps1
#   powershell -ExecutionPolicy Bypass -File labs\module-01\l1_0-orientation\check_environment.ps1 -h 127.0.0.1 -P 3307 -u root -p
# Arguments, when you give any, replace the default "-u root -p" and go to the mysql client unchanged.
# (PowerShell has no "<" redirection, so the script pipes the .sql file into the client instead.)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sql  = Join-Path $here 'check_environment.sql'

if (-not (Get-Command mysql -ErrorAction SilentlyContinue)) {
    Write-Output "NOT READY  the mysql client is not on your PATH (Lesson 1.2, Windows Step 4)."
    Write-Output "           Add C:\Program Files\MySQL\MySQL Server 9.7\bin to Path, then open a NEW PowerShell window."
    exit 1
}

$ver = (& mysql --version) -join ' '
Write-Output "client     $ver"
if ($ver -match 'MariaDB') {
    Write-Output "CHECK      a MariaDB client: it works with MySQL 9.7 for this course"
} elseif ($ver -match 'Ver (\d+)\.(\d+)') {
    $major = [int]$Matches[1]; $minor = [int]$Matches[2]
    if ($major -gt 9 -or ($major -eq 9 -and $minor -ge 7)) { Write-Output "OK         mysql client $major.$minor (9.7 or newer)" }
    elseif ($major -eq 8 -and $minor -eq 4) { Write-Output "CHECK      mysql client 8.4: fine for the course; outputs match 9.7 almost everywhere" }
    else { Write-Output "CHECK      mysql client $major.$minor is older than 8.4: install the 9.7 client (Lesson 1.2)" }
} else {
    Write-Output "CHECK      could not read the client version"
}

$clientArgs = if ($args.Count -gt 0) { $args } else { @('-u', 'root', '-p') }
Write-Output ("server     connecting with: mysql " + ($clientArgs -join ' '))
Get-Content -Raw $sql | & mysql @clientArgs --table
if ($LASTEXITCODE -ne 0) {
    Write-Output ""
    Write-Output "NOT READY  the client could not finish (read the ERROR line above):"
    Write-Output "           1045 = wrong user or password; 2003 = the server is not running, or wrong host/port"
    Write-Output "           (Lesson 1.2, Common Mistakes 2 and 3)."
    exit 1
}
