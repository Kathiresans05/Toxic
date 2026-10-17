import 'package:flutter/material.dart';
import 'package:expert_admin/theme/app_theme.dart';
import 'package:expert_admin/screens/dashboard_screens.dart';

import 'package:expert_admin/screens/admin_auth_screens.dart';

class PrototypeNavigator extends StatelessWidget {
  const PrototypeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <String, Widget>{
      '0. Admin Login & 2FA': const AdminLoginScreen(),
      '1. Admin Dashboard': const AdminDashboardScreen(),
      '2. User Management': const UserManagementScreen(),
      '3. Expert Verification': const ExpertManagementScreen(),
      '4. Analytics Overview': const AnalyticsScreen(),
      '5. Reports Menu List': const ReportsScreen(),
      '6. Platform Transactions': const TransactionsScreen(),
      '7. Settings Options': const SettingsScreen(),
      '8. Admin Profile Details': const AdminProfileScreen(),
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Console Prototypes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: screens.length,
          itemBuilder: (context, index) {
            final title = screens.keys.elementAt(index);
            final page = screens.values.elementAt(index);
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
