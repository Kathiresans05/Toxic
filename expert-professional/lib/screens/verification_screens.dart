import 'package:flutter/material.dart';
import 'package:expert_professional/theme/app_theme.dart';
import 'package:expert_professional/screens/dashboard_screens.dart';

// Expert Registration Screen
class ExpertRegistrationScreen extends StatefulWidget {
  const ExpertRegistrationScreen({super.key});

  @override
  State<ExpertRegistrationScreen> createState() => _ExpertRegistrationScreenState();
}

class _ExpertRegistrationScreenState extends State<ExpertRegistrationScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _expController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Expert Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Profile Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about your consulting experience...',
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),
            const Text('Years of Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _expController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 5',
                fillColor: AppTheme.cardColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VoiceVerificationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Proceed to Voice Check', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Voice Verification Screen
class VoiceVerificationScreen extends StatefulWidget {
  const VoiceVerificationScreen({super.key});

  @override
  State<VoiceVerificationScreen> createState() => _VoiceVerificationScreenState();
}

class _VoiceVerificationScreenState extends State<VoiceVerificationScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Voice Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Record a 10-second introduction sample to verify your audio voice output quality.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRecording = !_isRecording;
                });
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: _isRecording ? Colors.red : AppTheme.primary,
                child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording ? 'Recording voice sample...' : 'Tap Mic to Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isRecording ? Colors.red : Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KYCUploadScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Save & Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// KYC Upload Screen
class KYCUploadScreen extends StatelessWidget {
  const KYCUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Upload KYC Documents')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Creator Identity & Safety Validation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Upload official ID and record a voice verification sample for Admin KYC review.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            _buildUploadCard('Upload Aadhaar Card (Front)', Icons.add_photo_alternate, 'JPG/PNG document scan'),
            const SizedBox(height: 14),
            _buildUploadCard('Upload PAN Card Copy', Icons.credit_card_rounded, 'PAN document scan'),
            const SizedBox(height: 14),
            _buildUploadCard('Record Voice Verification Sample', Icons.mic_rounded, '10s Audio saying "I am ready to consult on ExpertApp"', isVoice: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WaitingForApprovalScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit KYC Verification', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(String label, IconData icon, String subtitle, {bool isVoice = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isVoice ? AppTheme.primary.withValues(alpha: 0.3) : Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isVoice ? AppTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            child: Icon(icon, size: 24, color: isVoice ? AppTheme.primary : Colors.white70),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isVoice ? AppTheme.primary : Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isVoice ? 'Record' : 'Upload',
              style: TextStyle(
                color: isVoice ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Waiting For Approval Screen
class WaitingForApprovalScreen extends StatelessWidget {
  const WaitingForApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 90, color: Colors.orange),
            const SizedBox(height: 30),
            const Text('Verification Pending', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              'Your documents have been submitted successfully. Our admin team will verify and approve your profile details in 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Direct to main dashboard for prototype purposes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpertDashboardScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Go to Dashboard', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
