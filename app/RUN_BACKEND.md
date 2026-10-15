# How to Run the Backend

## ✅ Correct Way

The project file is located in `backend\LocustMonitoring.API\`, so you need to navigate there first:

```powershell
cd backend\LocustMonitoring.API
dotnet run
```

## ✅ Alternative: From Root Directory

You can also run it from the root directory by specifying the project path:

```powershell
dotnet run --project backend\LocustMonitoring.API\LocustMonitoring.API.csproj
```

## ✅ Easiest Way: Use the Batch File

Just double-click `start_backend.bat` in the root directory, or run:

```powershell
.\start_backend.bat
```

## ❌ Wrong Way (This Won't Work)

```powershell
cd backend
dotnet run  # ❌ This will fail - no project file here
```

The project file (`LocustMonitoring.API.csproj`) is in `backend\LocustMonitoring.API\`, not in `backend\`.

## Current Status

The backend should already be running on **http://localhost:5000**

Check if it's running:
```powershell
netstat -ano | findstr :5000
```

If you see output, the backend is running! You can access:
- **API**: http://localhost:5000
- **Swagger UI**: http://localhost:5000/swagger

