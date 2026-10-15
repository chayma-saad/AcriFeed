@echo off
echo Setting up Locust Monitoring Database...
echo.
echo Please make sure XAMPP MySQL is running!
echo.

REM Try to find MySQL in common XAMPP locations
set MYSQL_PATH=
if exist "C:\xampp\mysql\bin\mysql.exe" set MYSQL_PATH=C:\xampp\mysql\bin\mysql.exe
if exist "D:\xampp\mysql\bin\mysql.exe" set MYSQL_PATH=D:\xampp\mysql\bin\mysql.exe

if "%MYSQL_PATH%"=="" (
    echo MySQL not found in common XAMPP locations.
    echo Please run the SQL script manually in phpMyAdmin:
    echo 1. Open http://localhost/phpmyadmin
    echo 2. Click on "SQL" tab
    echo 3. Copy and paste the contents of database\schema.sql
    echo 4. Click "Go"
    pause
    exit /b
)

echo Found MySQL at: %MYSQL_PATH%
echo.
echo Creating database and importing schema...
"%MYSQL_PATH%" -u root < database\schema.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Database setup completed successfully!
    echo.
    echo You can now login with:
    echo   Username: admin
    echo   Password: admin123
) else (
    echo.
    echo Database setup failed. Please check:
    echo 1. XAMPP MySQL service is running
    echo 2. MySQL root password (if set, update the script)
    echo.
    echo Alternatively, use phpMyAdmin to import database\schema.sql
)

pause

