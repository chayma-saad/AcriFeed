import 'package:flutter/foundation.dart';

class ApiConfig {
	static String get baseUrl {
		// Allow override via --dart-define=API_URL=...
		const String apiUrl = String.fromEnvironment('API_URL');
		if (apiUrl.isNotEmpty) {
			return apiUrl;
		}

		// Prefer HTTPS for web to avoid mixed-content and redirect issues.
		if (kIsWeb) {
			// Use HTTP in development to avoid self-signed certificate issues.
			return 'http://localhost:5000/api';
		}

		// Android emulator needs host loopback mapping.
		if (defaultTargetPlatform == TargetPlatform.android) {
			return 'http://10.0.2.2:5000/api';
		}

		// Default for desktop/iOS simulators.
		return 'http://localhost:5000/api';
	}
}

