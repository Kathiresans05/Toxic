import 'package:flutter/material.dart';
import 'package:expert_professional/theme/app_theme.dart';
import 'package:expert_professional/screens/expert_onboarding_screens.dart';
import 'package:expert_professional/screens/verification_screens.dart';
import 'package:expert_professional/screens/dashboard_screens.dart';
import 'package:expert_professional/screens/registration_screen.dart';

class PrototypeNavigator extends StatelessWidget {
  const PrototypeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <String, Widget>{
      '1. ConnectaX Landing': const ExpertLandingScreen(),
      '2. Why Become Expert': const WhyBecomeExpertScreen(),
      '3. Choose Role': const RoleSelectionScreen(),
      '4. Expert Login': const ExpertLoginScreen(),
      '5. Create Account Form': const CreateYourAccountScreen(),
      '6. Tell Us About You': const TellUsAboutYouScreen(),
      '7. Documents Verification': const DocumentsVerificationScreen(),
      '8. Registration Submitted': const RegistrationSubmittedScreen(),
      '10. Expert Profile Register': const RegistrationScreen(),
      '11. Voice Verification mic': const VoiceVerificationScreen(),
      '12. KYC Upload proofs': const KYCUploadScreen(),
      '13. Pending Approval Queue': const WaitingForApprovalScreen(),
      '14. Expert Console': const ExpertDashboardScreen(),
      '15. Session Earnings logs': const ExpertEarningsScreen(),
      '16. Request Payout UPI': const ExpertWithdrawRequestScreen(),
      '17. Analytics Charts': const ExpertAnalyticsScreen(),
      '18. Reviews Feed stars': const ExpertReviewsDashboardScreen(),
      '19. Configuration options': const SettingsScreen(),
      '20. Modify profile details': const EditProfileScreen(),
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Expert App Prototypes'),
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
