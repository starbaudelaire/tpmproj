@echo off
setlocal
cd /d "%~dp0"
echo Installing backend dependencies...
call npm install
if errorlevel 1 goto error

echo Setting up real PostgreSQL database...
call npm run setup
if errorlevel 1 goto error

echo Starting Jogjasplorasi backend...
call npm run dev
if errorlevel 1 goto error
exit /b 0

:error
echo.
echo Backend startup failed. Make sure Docker Desktop is running, then try again.
exit /b 1
