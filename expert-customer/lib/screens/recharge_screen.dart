import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _quickSelect(double value) {
    setState(() {
      _amountController.text = value.toStringAsFixed(0);
    });
  }

  void _recharge() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.rechargeWallet(amount);

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('Recharge Successful', style: TextStyle(color: Colors.white)),
            content: Text('₹${amount.toStringAsFixed(0)} has been credited to your wallet.', style: const TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
                child: const Text('OK', style: TextStyle(color: AppTheme.primary)),
              )
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recharge failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Recharge Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amount',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.bold),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickSelectButton(100),
                _buildQuickSelectButton(500),
                _buildQuickSelectButton(1000),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _recharge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Recharge Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(double value) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return ElevatedButton(
      onPressed: () => _quickSelect(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: textColor,
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text('+₹${value.toStringAsFixed(0)}'),
    );
  }
}
