import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';

// Referral Program Screen
class ReferralProgramScreen extends StatelessWidget {
  const ReferralProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 100, color: AppTheme.primary),
            const SizedBox(height: 30),
            Text('Invite Friends & Family', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            Text(
              'Share your code. If they register, you both get bonuses directly into your wallets!',
              textAlign: TextAlign.center,
              style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
              ),
              child: const Text(
                'CTX-SHARE2026',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral code copied to clipboard!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Copy Referral Code', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Notifications Screen
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final titles = ['Call Request Accepted', 'Wallet Top-up Successful', 'Welcome to ConnectaX!'];
          final subs = ['Your session with Sarah was accepted.', '₹500 has been credited to your balance.', 'Get matching with verified experts today.'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.notifications, color: Colors.white)),
              title: Text(titles[index], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              subtitle: Text(subs[index], style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}

// Favorites Screen
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('My Favorites')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 2,
        itemBuilder: (context, index) {
          final names = ['Sarah Jenkins', 'Monica Geller'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 15),
                    Text(names[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  ],
                ),
                const Icon(Icons.favorite, color: Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Call History Screen
class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Call History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final names = ['Sarah Jenkins', 'Rajesh Kumar', 'Sarah Jenkins'];
          final dates = ['15 July, 10:30 AM', '12 July, 05:15 PM', '10 July, 02:40 PM'];
          final durations = ['15 min', '8 min', '24 min'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.call)),
              title: Text(names[index], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              subtitle: Text('$dates • $durations', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}

// Ratings Screen
class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Ratings & Reviews')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('4.8 ⭐', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            Text('Based on 24 reviews', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Report Expert Screen
class ReportExpertScreen extends StatelessWidget {
  const ReportExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Report Expert')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason for Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Enter reason here (e.g. Spam, Inappropriate behavior)',
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              maxLines: 4,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 65)),
            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.grey),
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Help Center Screen
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Help Center')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Need Help? Send a message to our Support Team.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your issue here...',
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket sent.')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ Screen
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ExpansionTile(
            title: Text('How does billing work?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [Padding(padding: EdgeInsets.all(15), child: Text('Billing is calculated per-minute and deducted directly from your wallet balance during calls.'))],
          ),
          ExpansionTile(
            title: Text('How do I recharge my wallet?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [Padding(padding: EdgeInsets.all(15), child: Text('Go to Wallet tab and click Add Money. Select a pack and proceed to checkout.'))],
          ),
        ],
      ),
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isLight ? Colors.white : AppTheme.cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Safety & Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Trust Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.85),
                    const Color(0xFF4338CA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.shield_rounded, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Comes First',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '100% Private, Anonymous & End-to-End Encrypted communication.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Our Core Commitments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),

            _buildPillarCard(
              context: context,
              cardBg: cardBg,
              textColor: textColor,
              icon: Icons.person_off_rounded,
              iconColor: const Color(0xFF10B981),
              title: '100% Anonymous & Private',
              desc: 'Your phone number, payment information, and personal identity are never disclosed to experts or companions. You talk in complete anonymity.',
            ),

            const SizedBox(height: 12),
            _buildPillarCard(
              context: context,
              cardBg: cardBg,
              textColor: textColor,
              icon: Icons.lock_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'End-to-End Encrypted',
              desc: 'All real-time text chats, voice notes, and calls use secure encryption protocols. No unauthorized third parties can access your conversations.',
            ),

            const SizedBox(height: 12),
            _buildPillarCard(
              context: context,
              cardBg: cardBg,
              textColor: textColor,
              icon: Icons.videocam_off_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'Zero Call Recording Policy',
              desc: 'Live audio and video consultations are ephemeral direct WebRTC streams. We do NOT record, intercept, or save session streams on our servers.',
            ),

            const SizedBox(height: 12),
            _buildPillarCard(
              context: context,
              cardBg: cardBg,
              textColor: textColor,
              icon: Icons.verified_user_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'Safety Controls & Community Standards',
              desc: 'We enforce a strict zero-tolerance policy for harassment or inappropriate behavior. You can block or report any account instantly.',
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLight ? Colors.grey.shade100 : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.white10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: isLight ? Colors.grey.shade700 : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For legal or privacy queries, contact our support team at support@connectax.app',
                      style: TextStyle(color: isLight ? Colors.grey.shade700 : Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _buildPillarCard({
    required BuildContext context,
    required Color cardBg,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: isLight ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
