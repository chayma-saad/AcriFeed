# AI-Vision Locust Monitoring App

A comprehensive monitoring application for locust farm management with AI-powered vision analysis, real-time environmental monitoring, and intelligent recommendations.

## Project Structure

```
app/
├── frontend/          # Flutter application
├── backend/           # .NET Web API
└── database/          # SQL scripts and schema
```

## Features

- 🎥 Real-time AI-Vision feed with condition detection
- 📊 Environmental monitoring and charts
- 📝 Historical logs and analytics
- 🤖 AI Chatbot assistant
- 🔔 Push notifications for critical conditions
- 📱 Cross-platform (Android, iOS, Windows, Mac)

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: .NET 8.0 Web API (C#)
- **Database**: MySQL (XAMPP)

## Setup Instructions

### Database Setup
1. Start XAMPP and MySQL service
2. Run the SQL scripts in `database/` folder
3. Update connection string in `backend/appsettings.json`

### Backend Setup
1. Navigate to `backend/` folder
2. Run `dotnet restore`
3. Run `dotnet run`

### Frontend Setup
1. Navigate to `frontend/` folder
2. Run `flutter pub get`
3. Run `flutter run`

## API Endpoints

- `POST /api/auth/login` - User authentication
- `GET /api/predictions/latest` - Get latest prediction
- `POST /api/predictions` - Submit new prediction
- `GET /api/predictions` - Get predictions with date filters
- `GET /api/environmental/latest` - Get latest environmental data
- `GET /api/environmental` - Get environmental data with date filters
- `GET /api/history` - Get historical logs with date filters
- `POST /api/chatbot/ask` - Chatbot queries
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications/{id}/read` - Mark notification as read
- `POST /api/actions` - Record action taken

## Quick Start

1. **Setup Database**: Run `database/schema.sql` in XAMPP MySQL
2. **Start Backend**: `cd backend/LocustMonitoring.API && dotnet run`
3. **Start Frontend**: `cd frontend && flutter run`
4. **Login**: Use `admin` / `admin123`

See `SETUP.md` for detailed instructions.

