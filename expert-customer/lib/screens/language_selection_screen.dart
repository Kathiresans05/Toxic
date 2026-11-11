import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/screens/login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'icon': '📞'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'icon': 'அ'},
    {'name': 'Hindi', 'native': 'हिंदी', 'icon': 'अ'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'icon': 'అ'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'icon': 'ಅ'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'icon': 'அ'},
  ];
  late List<String> _selectedLangs;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _selectedLangs = List<String>.from(authProvider.preferredLanguages);
      if (_selectedLangs.isEmpty) {
        _selectedLangs = ['Tamil', 'English'];
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2),
                children: [
                  TextSpan(text: 'Choose Your\n'),
                  TextSpan(text: 'Preferred Languages', style: TextStyle(color: Color(0xFFFFC107))),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Select one or more languages.\nWe will show experts who speak your language first!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLangs.contains(lang['name']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_selectedLangs.length > 1) {
                              _selectedLangs.remove(lang['name']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please keep at least 1 preferred language')),
                              );
                            }
                          } else {
                            _selectedLangs.add(lang['name']!);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF8E1) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFFC107) : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFE082) : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: lang['icon'] == '📞' 
                                    ? const Icon(Icons.phone_in_talk, color: Colors.black87, size: 20)
                                    : Text(lang['icon']!, style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lang['native']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  if (lang['name'] != lang['native'])
                                    Text(lang['name']!, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFFFFC107))
                            else
                              const Icon(Icons.circle_outlined, color: Colors.black26),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.updatePreferredLanguages(_selectedLangs);
                    if (!mounted) return;
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Save & Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
