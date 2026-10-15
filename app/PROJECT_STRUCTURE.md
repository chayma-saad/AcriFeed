# Project Structure

## Directory Layout

```
app/
├── backend/
│   └── LocustMonitoring.API/
│       ├── Controllers/          # API Controllers
│       │   ├── AuthController.cs
│       │   ├── PredictionsController.cs
│       │   ├── EnvironmentalController.cs
│       │   ├── HistoryController.cs
│       │   ├── ChatbotController.cs
│       │   ├── NotificationsController.cs
│       │   └── ActionsController.cs
│       ├── Data/                 # Database Context
│       │   └── ApplicationDbContext.cs
│       ├── Models/               # Entity Models
│       │   ├── User.cs
│       │   ├── EnvironmentalData.cs
│       │   ├── Prediction.cs
│       │   ├── ActionTaken.cs
│       │   └── Notification.cs
│       ├── DTOs/                 # Data Transfer Objects
│       │   ├── LoginRequest.cs
│       │   ├── LoginResponse.cs
│       │   ├── PredictionRequest.cs
│       │   └── PredictionResponse.cs
│       ├── Services/              # Business Logic
│       │   ├── IAuthService.cs / AuthService.cs
│       │   ├── IPredictionService.cs / PredictionService.cs
│       │   ├── IEnvironmentalService.cs / EnvironmentalService.cs
│       │   ├── IHistoryService.cs / HistoryService.cs
│       │   ├── IChatbotService.cs / ChatbotService.cs
│       │   └── INotificationService.cs / NotificationService.cs
│       ├── Program.cs            # Application Entry Point
│       ├── appsettings.json      # Configuration
│       └── LocustMonitoring.API.csproj
│
├── frontend/
│   └── lib/
│       ├── main.dart             # App Entry Point
│       ├── screens/              # UI Screens
│       │   ├── login_screen.dart
│       │   ├── home_screen.dart
│       │   ├── charts_screen.dart
│       │   ├── history_screen.dart
│       │   └── chatbot_screen.dart
│       ├── widgets/              # Reusable Widgets
│       │   ├── dashboard_widget.dart
│       │   ├── condition_overlay.dart
│       │   ├── recommended_actions_panel.dart
│       │   └── quick_stats_widget.dart
│       └── services/             # API & Business Logic
│           ├── api_service.dart
│           └── auth_service.dart
│
└── database/
    └── schema.sql                # Database Schema
```

## Key Features Implemented

### Backend (.NET)
- ✅ JWT Authentication
- ✅ RESTful API with Swagger documentation
- ✅ Entity Framework Core with MySQL
- ✅ AI Prediction Service (rule-based, ready for ML integration)
- ✅ Environmental Data Management
- ✅ Historical Logging
- ✅ Chatbot Service
- ✅ Notification System

### Frontend (Flutter)
- ✅ Login/Authentication Screen
- ✅ Dashboard with Live Feed Simulation
- ✅ Real-time Condition Overlay
- ✅ Recommended Actions Panel
- ✅ Quick Stats Widget
- ✅ Environmental Charts (Temperature, Humidity, Activity)
- ✅ Historical Log View
- ✅ Chatbot Assistant
- ✅ Notifications System
- ✅ Cross-platform Support (Android, iOS, Windows, Mac)

### Database (MySQL)
- ✅ Users table
- ✅ Environmental Data table
- ✅ Predictions table
- ✅ Actions Taken table
- ✅ Notifications table

## API Endpoints Summary

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/login` | User login | No |
| GET | `/api/predictions/latest` | Get latest prediction | Yes |
| POST | `/api/predictions` | Create new prediction | Yes |
| GET | `/api/predictions` | Get predictions (filtered) | Yes |
| GET | `/api/environmental/latest` | Get latest environmental data | Yes |
| GET | `/api/environmental` | Get environmental data (filtered) | Yes |
| GET | `/api/history` | Get historical logs | Yes |
| POST | `/api/chatbot/ask` | Ask chatbot question | Yes |
| GET | `/api/notifications` | Get notifications | Yes |
| POST | `/api/notifications/{id}/read` | Mark notification as read | Yes |
| POST | `/api/actions` | Record action taken | Yes |

## Next Steps for Production

1. **AI Model Integration**: Replace rule-based prediction with actual ML model
2. **Password Security**: Implement proper BCrypt hashing
3. **Video Feed**: Integrate actual camera feed for real-time processing
4. **Push Notifications**: Implement Firebase Cloud Messaging
5. **File Storage**: Add image/video storage for frame data
6. **CORS Configuration**: Update for production domains
7. **Error Handling**: Enhanced error handling and logging
8. **Unit Tests**: Add comprehensive test coverage
9. **CI/CD**: Set up deployment pipeline
10. **Documentation**: API documentation and user guides

