import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    debugPrint('Skipping Firebase initialization on web: no Firebase web config is configured for this project.');
  } else {
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      // If Firebase fails to initialize (e.g., missing platform config),
      // log the error and continue so the app can run in a degraded mode.
      debugPrint('Firebase initialization failed: $e');
      debugPrint('$st');
    }
  }

  runApp(const SecureTrackApp());
}

class SecureTrackApp extends StatelessWidget {
  const SecureTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'C GO',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}