import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/screens/onboarding_screens.dart';
import 'package:expert_customer/screens/language_selection_screen.dart';
import 'package:expert_customer/screens/login_screen.dart';
import 'package:expert_customer/screens/customer_registration_screen.dart';
import 'package:expert_customer/screens/main_layout_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart';
import 'package:expert_customer/screens/wallet_screens.dart';
import 'package:expert_customer/screens/profile_screens.dart';
import 'package:expert_customer/screens/transactions_screen.dart';
import 'package:expert_customer/screens/recharge_screen.dart';
import 'package:expert_customer/screens/call_screen.dart';

class PrototypeNavigator extends StatelessWidget {
  const PrototypeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <String, Widget>{
      '1. Splash Screen': const SplashScreen(),
      '2. Onboarding Page 1': const SplashScreen(),
      '3. Onboarding Page 2': const SplashScreen(),
      '5. Language Selection': const LanguageSelectionScreen(),
      '6. Login Page': const LoginScreen(),
      '8. Registration Profile': const CustomerRegistrationScreen(),
      '9. Home Dashboard': const MainLayoutScreen(),
      '10. Search Experts': const SearchExpertsScreen(),
      '11. Expert Categories': const ExpertCategoriesScreen(),
      '12. Experts List': const ExpertListScreen(categoryName: 'Relationship'),
      '13. Expert Profile': const ExpertProfileScreen(name: 'Sarah Jenkins', rate: 5.0),
      '14. Expert Reviews': const ExpertReviewsScreen(expertName: 'Sarah Jenkins'),
      '15. Expert Availability': const ExpertAvailabilityScreen(expertName: 'Sarah Jenkins'),
      '16. Audio Connecting': const CallScreen(expertName: 'Sarah Jenkins', expertId: '123', pricePerMinute: 5.0, callType: 'audio'),
      '17. Video Connecting': const CallScreen(expertName: 'Sarah Jenkins', expertId: '123', pricePerMinute: 5.0, callType: 'video'),
      '18. Match Radar radar': const RandomMatchScreen(),
      '19. Wallet Home': const WalletHomeScreen(),
      '20. Add Money': const AddMoneyScreen(),
      '21. Recharge Packs': const RechargePacksScreen(),
      '22. Payment Success': const PaymentSuccessScreen(amount: 500.0),
      '23. Transaction Ledger': const TransactionsScreen(),
      '24. Referral Page': const ReferralProgramScreen(),
      '25. System Notifications': const NotificationsScreen(),
      '26. Favorites List': const FavoritesScreen(),
      '27. Call History logs': const CallHistoryScreen(),
      '28. Feedback Star Rating': const RatingsScreen(),
      '29. Report/Block Form': const ReportExpertScreen(),
      '30. App Configurations': const SettingsScreen(),
      '31. Profile Modifications': const EditProfileScreen(),
      '32. Support Help Tickets': const HelpCenterScreen(),
      '33. FAQ Accordions': const FAQScreen(),
      '34. Privacy Policy': const PrivacyPolicyScreen(),
      '35. Recharge Screen (Custom)': const RechargeScreen(),
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Customer App Prototypes'),
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
