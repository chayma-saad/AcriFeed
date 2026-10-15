# Setup Instructions

## Prerequisites

1. **XAMPP** - Install and start MySQL service
2. **.NET 8.0 SDK** - For backend API
3. **Flutter SDK** - For frontend application
4. **Visual Studio Code** or **Visual Studio** (for .NET development)

## Database Setup

1. Start XAMPP and ensure MySQL service is running
2. Open phpMyAdmin (http://localhost/phpmyadmin)
3. Import the database schema:
   - Navigate to `database/schema.sql`
   - Copy the contents
   - In phpMyAdmin, select "SQL" tab and paste the contents
   - Execute the script

Alternatively, you can run the SQL script directly:
```bash
mysql -u root -p < database/schema.sql
```

## Backend Setup (.NET)

1. Navigate to the backend directory:
```bash
cd backend/LocustMonitoring.API
```

2. Restore NuGet packages:
```bash
dotnet restore
```

3. Update the connection string in `appsettings.json` if needed:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=locust_monitoring;User=root;Password=;Port=3306;"
}
```

4. Run the API:
```bash
dotnet run
```

The API will be available at `http://localhost:5000` (or the port shown in the console).

5. Test the API:
   - Open `http://localhost:5000/swagger` in your browser
   - You should see the Swagger UI with all available endpoints

## Frontend Setup (Flutter)

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Update API base URL in `lib/services/api_service.dart`:
   - For Android Emulator: Use `http://10.0.2.2:5000/api`
   - For iOS Simulator: Use `http://localhost:5000/api`
   - For Physical Device: Use your computer's IP address (e.g., `http://192.168.1.100:5000/api`)

4. Run the Flutter app:
```bash
flutter run
```

## Default Login Credentials

- **Username**: `admin`
- **Password**: `admin123`

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login

### Predictions
- `GET /api/predictions/latest` - Get latest prediction
- `POST /api/predictions` - Create new prediction
- `GET /api/predictions` - Get predictions with optional date filters

### Environmental Data
- `GET /api/environmental/latest` - Get latest environmental data
- `GET /api/environmental` - Get environmental data with optional date filters

### History
- `GET /api/history` - Get historical logs with optional date filters

### Chatbot
- `POST /api/chatbot/ask` - Ask chatbot a question

### Notifications
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications/{id}/read` - Mark notification as read

## Troubleshooting

### Backend Issues

1. **Database Connection Error**:
   - Ensure MySQL is running in XAMPP
   - Check connection string in `appsettings.json`
   - Verify database `locust_monitoring` exists

2. **Port Already in Use**:
   - Change the port in `launchSettings.json` or use `dotnet run --urls "http://localhost:5001"`

### Frontend Issues

1. **API Connection Error**:
   - Verify backend is running
   - Check API base URL in `api_service.dart`
   - For physical devices, ensure device and computer are on the same network

2. **Build Errors**:
   - Run `flutter clean` and `flutter pub get`
   - Ensure Flutter SDK is up to date

## Development Notes

- The AI prediction logic is currently simplified (rule-based). In production, replace with actual ML model.
- Password hashing is simplified for demo. Use BCrypt in production.
- CORS is configured for local development. Update for production deployment.

