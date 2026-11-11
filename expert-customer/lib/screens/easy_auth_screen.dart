import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/screens/main_layout_screen.dart';
import 'package:expert_customer/screens/login_screen.dart';

class EasyAuthScreen extends StatefulWidget {
  const EasyAuthScreen({super.key});

  @override
  State<EasyAuthScreen> createState() => _EasyAuthScreenState();
}

class _EasyAuthScreenState extends State<EasyAuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Preferred Languages selection
  final List<String> _availableLanguages = ['Tamil', 'English', 'Hindi', 'Telugu', 'Kannada', 'Malayalam'];
  final List<String> _selectedLanguages = ['Tamil', 'English'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Name, Mobile Number, and Password')),
      );
      return;
    }

    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one preferred language')),
      );
      return;
    }

    final email = phone.contains('@') ? phone : '$phone@expert.com';
    final prefLang = _selectedLanguages.join(', ');

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signUp(
      email,
      password,
      name,
      phone,
      preferredLanguage: prefLang,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // App Logo Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.call_rounded, color: Colors.black, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ConnectaX',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Title
              Text(
                'Welcome! 👋',
                style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your details to get started with expert consultations',
                style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontSize: 15),
              ),
              const SizedBox(height: 25),

              // Quick Access Form
              _buildInputField(
                label: 'Your Name',
                controller: _nameController,
                hint: 'e.g. Rahul',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Mobile Number',
                controller: _phoneController,
                hint: 'e.g. 9876543210',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isDark: isDark,
                textColor: textColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Preferred Language(s)',
                style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _availableLanguages.map((lang) {
                  final isSelected = _selectedLanguages.contains(lang);
                  return ChoiceChip(
                    label: Text(lang),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLanguages.add(lang);
                        } else {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : const Text('Continue to App ➔', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already registered? ',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login to Account',
                      style: TextStyle(
                        color: Color(0xFFF57F17),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white12 : AppTheme.lightCardBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: TextStyle(color: textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
              prefixIcon: Icon(icon, color: AppTheme.secondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
