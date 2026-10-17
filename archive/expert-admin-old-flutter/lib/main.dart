import 'package:flutter/material.dart';
import 'package:expert_admin/theme/app_theme.dart';
import 'package:expert_admin/screens/prototype_navigator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ConnectaXAdminApp());
}

class ConnectaXAdminApp extends StatelessWidget {
  const ConnectaXAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectaX Admin Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PrototypeNavigator(),
    );
  }
}
