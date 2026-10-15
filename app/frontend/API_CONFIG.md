# API Configuration Guide

## Base URL Configuration

The API base URL needs to be configured differently depending on where you're running the Flutter app.

### Current Configuration

The base URL is set in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Platform-Specific URLs

#### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

#### iOS Simulator
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

#### Physical Device (Same Network)
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
2. Use your computer's IP:
```dart
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

#### Web (Flutter Web)
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Dynamic Configuration (Recommended)

For a more flexible setup, you can use environment variables or a config file:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static String get baseUrl {
    // You can check the platform and return appropriate URL
    // Or use environment variables
    const String? apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl != null && apiUrl.isNotEmpty) {
      return apiUrl;
    }
    
    // Default fallback
    return 'http://localhost:5000/api';
  }
}
```

Then in `api_service.dart`:
```dart
import '../config/api_config.dart';

static String get baseUrl => ApiConfig.baseUrl;
```

### Running with Custom URL

```bash
# Android
flutter run --dart-define=API_URL=http://10.0.2.2:5000/api

# iOS
flutter run --dart-define=API_URL=http://localhost:5000/api

# Physical Device
flutter run --dart-define=API_URL=http://192.168.1.100:5000/api
```

### Troubleshooting Connection Issues

1. **Backend not accessible**:
   - Ensure backend is running: `dotnet run` in backend directory
   - Check if port 5000 is open
   - Verify firewall settings

2. **CORS errors**:
   - Backend should allow CORS for your frontend origin
   - Check `Program.cs` CORS configuration

3. **Connection refused**:
   - Verify the IP address is correct
   - Ensure device and computer are on the same network
   - Check backend is listening on the correct interface (0.0.0.0, not just localhost)

