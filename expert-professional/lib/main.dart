import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/theme/app_theme.dart';
import 'package:expert_professional/screens/expert_onboarding_screens.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/screens/expert_dashboard_screen.dart';
import 'package:expert_professional/services/foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize ForegroundService singleton and method call handlers
  ForegroundService();
  
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
    print(">>> CONNECTAX_DEBUG: ConnectaXApp.build() called");
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'ConnectaX Expert Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LauncherScreen(),
    );
  }
}

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        print(">>> CONNECTAX_DEBUG: LauncherScreen.build() isInitialized=${auth.isInitialized}, isLoggedIn=${auth.isLoggedIn}, user=${auth.user}");
        if (!auth.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFF08080A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            ),
          );
        }

        if (!auth.isLoggedIn) {
          return const ExpertLandingScreen();
        }

        final user = auth.user ?? {};
        if (user['name'] == null || user['name'].toString().isEmpty) {
          return const TellUsAboutYouScreen();
        }

        return const ExpertDashboardScreen();
      },
    );
  }
}
