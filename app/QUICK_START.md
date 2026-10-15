# Quick Start Guide

## Starting the Backend

### Option 1: Using the Batch File (Easiest)
Double-click `start_backend.bat` in the root directory.

### Option 2: Using Command Line
```powershell
cd backend\LocustMonitoring.API
dotnet run
```

### Option 3: From Root Directory
```powershell
dotnet run --project backend\LocustMonitoring.API\LocustMonitoring.API.csproj
```

## Starting the Frontend

### Option 1: Using Command Line
```powershell
cd ..   # the Flutter app is at the repository root
flutter run
```

Then select your device (Chrome, Windows, etc.)

### Option 2: Specify Device Directly
```powershell
cd ..   # the Flutter app is at the repository root
flutter run -d chrome
```

## Important Notes

1. **Backend must be in `backend\LocustMonitoring.API` directory** - The `.csproj` file is there, not in the `backend` folder directly.

2. **Database Setup Required**: Before login works, you must:
   - Start XAMPP MySQL
   - Import `database\schema.sql` in phpMyAdmin

3. **Default Login**:
   - Username: `admin`
   - Password: `admin123`

## Troubleshooting

### "Couldn't find a project to run"
- Make sure you're in the `backend\LocustMonitoring.API` directory
- Or use: `dotnet run --project backend\LocustMonitoring.API\LocustMonitoring.API.csproj`

### Backend won't start
- Check if port 5000 is already in use
- Kill existing processes: `Get-Process | Where-Object {$_.ProcessName -like "*LocustMonitoring*"} | Stop-Process -Force`

### Database connection errors
- Ensure MySQL is running in XAMPP
- Check connection string in `backend\LocustMonitoring.API\appsettings.json`

