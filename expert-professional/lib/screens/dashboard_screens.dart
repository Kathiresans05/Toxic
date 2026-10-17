import 'package:flutter/material.dart';
import 'package:expert_professional/theme/app_theme.dart';

// Expert Dashboard Screen
class ExpertDashboardScreen extends StatefulWidget {
  const ExpertDashboardScreen({super.key});

  @override
  State<ExpertDashboardScreen> createState() => _ExpertDashboardScreenState();
}

class _ExpertDashboardScreenState extends State<ExpertDashboardScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Expert Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isOnline ? Colors.green : Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: _isOnline ? Colors.green : Colors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Ready to consult', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _isOnline,
                    activeThumbColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _isOnline = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Console Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildStatTile('Weekly Earnings', '₹4,300', Icons.wallet, Colors.green),
                _buildStatTile('Total Sessions', '32 Calls', Icons.phone, AppTheme.primary),
                _buildStatTile('Average Rating', '4.9 ⭐', Icons.star, Colors.orange),
                _buildStatTile('Withdrawals', '₹1,500', Icons.outbox, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Expert Earnings Screen
class ExpertEarningsScreen extends StatelessWidget {
  const ExpertEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Earnings History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (context, index) {
          final dates = ['Today, 02:40 PM', 'Yesterday, 10:15 AM', '14 July, 05:00 PM', '12 July, 09:30 AM'];
          final hours = ['15 mins', '24 mins', '6 mins', '45 mins'];
          final earnings = [150, 240, 60, 450];
          return ListTile(
            title: Text('Session Earnings', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${dates[index]} • ${hours[index]}'),
            trailing: Text('+₹${earnings[index]}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          );
        },
      ),
    );
  }
}

// Withdraw Request
class ExpertWithdrawRequestScreen extends StatelessWidget {
  const ExpertWithdrawRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Request Payout')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Payout Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                prefixText: '₹ ',
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('UPI Address (VPA) / Bank Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. mobile@upi',
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request submitted.')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Request Withdrawal', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Expert Analytics
class ExpertAnalyticsScreen extends StatelessWidget {
  const ExpertAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Earnings Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Analytics Mockup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: const Center(
                child: Text('Bar Graph Mockup here', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Weekly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildSummaryRow('Peak Day', 'Wednesday'),
            _buildSummaryRow('Peak Hours', '06:00 PM - 09:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Reviews Dashboard
class ExpertReviewsDashboardScreen extends StatelessWidget {
  const ExpertReviewsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Client Reviews Feed')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final ratings = [5, 4, 5];
          final comments = ['Sarah Jenkins is very empathetic and professional.', 'Good session, helpful hints.', 'Wonderful counselor. highly recommended.'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Client Session', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: List.generate(ratings[index], (index) => const Icon(Icons.star, color: Colors.orange, size: 16))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(comments[index], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
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
      appBar: AppBar(title: const Text('Expert Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile Details'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Earnings History Logs'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpertEarningsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('View Analytics Graphs'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpertAnalyticsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.outbox),
            title: const Text('Request Payouts'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpertWithdrawRequestScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('User Reviews Feed'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpertReviewsDashboardScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// Edit Profile
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Modify Profile details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 65)),
            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: 'Consultant Bio',
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
                child: const Text('Save Expert Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
