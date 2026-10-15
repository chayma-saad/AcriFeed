@echo off
echo Starting Locust Monitoring Backend API...
echo.
cd /d "%~dp0backend\LocustMonitoring.API"
dotnet run
pause

