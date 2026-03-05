@echo off
setlocal
set SCRIPT_DIR=%~dp0
set JAR=%SCRIPT_DIR%cobol-check-0.2.9.jar

if not exist "%JAR%" (
  echo ERROR: %JAR% not found. Please place cobol-check-0.2.9.jar in %SCRIPT_DIR%
  exit /b 1
)

java -jar "%JAR%" %*
``