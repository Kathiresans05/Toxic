import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/screens/main_layout_screen.dart';
import 'package:expert_customer/services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  final List<String> _languages = [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Bengali',
  ];

  void _submitProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      
      final response = await apiService.client.put('/users/profile', data: {
        'name': _nameController.text.trim(),
        'preferredLanguage': _selectedLanguage,
        'referralCode': _referralController.text.trim().toUpperCase(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        }
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Complete Profile',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tell us a bit about yourself to get started.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.person, color: AppTheme.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.language, color: AppTheme.primary),
                    hintText: 'Select Preferred Language',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  items: _languages.map((String lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _referralController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Referral Code (Optional)',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.card_giftcard, color: AppTheme.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save & Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
