import 'package:flutter/material.dart';
import 'package:expert_professional/screens/expert_dashboard_screen.dart';
import 'package:expert_professional/services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  static const Color _bgDark = Color(0xFF08080A);
  static const Color _cardBg = Color(0xFF141418);
  static const Color _yellowAccent = Color(0xFFFFC107);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _borderColor = Color(0xFF26262B);

  final Map<String, bool> _supportedLanguages = {
    'Tamil': true,
    'English': true,
    'Hindi': false,
    'Telugu': false,
    'Kannada': false,
    'Malayalam': false,
    'Marathi': false,
    'Bengali': false,
  };

  bool _isLoading = false;

  void _submitProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    final selectedLanguages = _supportedLanguages.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      
      final userResponse = await apiService.client.put('/users/profile', data: {
        'name': _nameController.text.trim(),
        'preferredLanguage': selectedLanguages.first,
        'bio': _bioController.text.trim(),
      });

      if (userResponse.statusCode == 200 || userResponse.statusCode == 201) {
        await apiService.client.put('/experts/status', data: {
          'isOnline': false,
        });
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ExpertDashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Profile submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),

              // Heading
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Complete Your\n',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Expert Profile ✨',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: _yellowAccent,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us a bit about yourself to complete your account setup.',
                style: TextStyle(color: _textMuted, fontSize: 15),
              ),

              const SizedBox(height: 32),

              // Full Name Field Label
              const Text(
                'Full Name',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: _textMuted),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: _yellowAccent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bio / Specialization
              const Text(
                'Short Bio & Experience',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 5+ years experience guiding relationship & life decisions...',
                    hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.description_outlined, color: _yellowAccent),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Languages Selection Header
              const Text(
                'Languages You Speak',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select all languages you can comfortably consult in',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Language Chip Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _supportedLanguages.keys.map((lang) {
                  final isSelected = _supportedLanguages[lang] ?? false;
                  return ChoiceChip(
                    label: Text(lang),
                    selected: isSelected,
                    selectedColor: _yellowAccent,
                    backgroundColor: _cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? _yellowAccent : _borderColor,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _supportedLanguages[lang] = selected;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellowAccent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
