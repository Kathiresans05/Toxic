import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/theme/app_theme.dart';
import 'package:expert_professional/screens/expert_onboarding_screens.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:expert_professional/screens/expert_dashboard_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const ConnectaXApp(),
    ),
  );
}

class ConnectaXApp extends StatelessWidget {
  const ConnectaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectaX Expert Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LauncherScreen(),
    );
  }
}

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  void _routeUser(BuildContext context, AuthProvider auth) {
    if (!auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExpertLandingScreen()),
      );
      return;
    }

    final user = auth.user ?? {};
    if (user['name'] == null || user['name'].toString().isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExpertDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFF08080A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            ),
          );
        }

        // Trigger navigation after build frame finishes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _routeUser(context, auth);
        });

        return const Scaffold(
          backgroundColor: Color(0xFF08080A),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          ),
        );
      },
    );
  }
}
