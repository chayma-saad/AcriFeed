import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/ml_service_http.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final databaseService = DatabaseService();
  final authService = AuthService();
  final mlService = MLService();

  // Try to connect to MySQL (will fail gracefully on web)
  try {
    await databaseService.connect();
  } catch (e) {
    debugPrint('Database connection failed (this is expected on web): $e');
    // Continue anyway - app can work with API only
  }

  // Check ML backend connection (non-blocking)
  unawaited(mlService.checkConnection().then((connected) {
    debugPrint('ML Backend connected: $connected');
  }).catchError((e) {
    debugPrint('ML Backend check failed: $e');
  }));

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => databaseService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        Provider(create: (context) => mlService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return MaterialApp(
          title: 'AcriFeed',
          theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          locale: languageService.locale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: LanguageService.localizationsDelegates,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}