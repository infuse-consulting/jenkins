@SETLOCAL ENABLEEXTENSIONS
@ECHO OFF
SET wd=%programfiles(x86)%\Infuse Consulting\useMango\App
ECHO Running test '%3' from project %2 on server %1
"%wd%\MangoMotor.exe" -s %1 -p %2 --testname %3 