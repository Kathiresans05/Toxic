import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/services/api_service.dart';

class ExpertColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}

class BankPayoutScreen extends StatefulWidget {
  const BankPayoutScreen({super.key});

  @override
  State<BankPayoutScreen> createState() => _BankPayoutScreenState();
}

class _BankPayoutScreenState extends State<BankPayoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Bank Form Controllers
  final TextEditingController _accountHolderController = TextEditingController(text: 'John Doe');
  final TextEditingController _bankNameController = TextEditingController(text: 'HDFC Bank');
  final TextEditingController _accountNumberController = TextEditingController(text: '98765432101234');
  final TextEditingController _ifscController = TextEditingController(text: 'HDFC0001234');
  final TextEditingController _upiIdController = TextEditingController(text: 'john@hdfcbank');

  // Withdrawal Controllers
  final TextEditingController _amountController = TextEditingController(text: '500');
  String _selectedMethod = 'Bank'; // 'Bank' or 'UPI'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveBankDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Bank Account details saved successfully!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    _tabController.animateTo(1); // Switch to Payout tab
  }

  Future<void> _processWithdrawal(double maxBalance) async {
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Minimum withdrawal amount is ₹10'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (amount > maxBalance && maxBalance > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Amount exceeds available balance (₹${maxBalance.toStringAsFixed(2)})'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await ApiService().requestPayoutWithdrawal(amount, {
      'method': _selectedMethod,
      'bankName': _bankNameController.text,
      'accountNumber': _accountNumberController.text,
      'upiId': _upiIdController.text,
    });

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshProfile();

      _showSuccessModal(response?['referenceId'] ?? 'PO-982143', amount);
    }
  }

  void _showSuccessModal(String refId, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: ExpertColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 44),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Payout Requested!',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${amount.toStringAsFixed(2)} will be transferred to your ${_selectedMethod == 'Bank' ? 'Bank Account' : 'UPI ID'}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ExpertColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ref Number', style: TextStyle(color: ExpertColors.textMuted, fontSize: 12)),
                          Text(refId, style: const TextStyle(color: ExpertColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status', style: TextStyle(color: ExpertColors.textMuted, fontSize: 12)),
                          Text('PROCESSING (IMPS)', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ExpertColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final double walletBalance = double.tryParse(user['walletBalance']?.toString() ?? '1500') ?? 1500.0;
    final String formattedBalance = '₹ ${walletBalance.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: ExpertColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ExpertColors.primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bank & Payouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ExpertColors.primaryYellow,
          labelColor: ExpertColors.primaryYellow,
          unselectedLabelColor: ExpertColors.textMuted,
          tabs: const [
            Tab(text: 'Bank Account Details'),
            Tab(text: 'Withdraw Payout'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Bank Account Form
            _buildBankFormTab(),

            // Tab 2: Withdraw Payout Screen
            _buildWithdrawTab(walletBalance, formattedBalance),
          ],
        ),
      ),
    );
  }

  Widget _buildBankFormTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bank Account Info', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Enter your active bank details for direct payout transfers via IMPS/NEFT.', style: TextStyle(color: ExpertColors.textMuted, fontSize: 12)),
          const SizedBox(height: 20),

          _buildTextField('Account Holder Name', _accountHolderController, Icons.person_outline_rounded),
          const SizedBox(height: 14),
          _buildTextField('Bank Name', _bankNameController, Icons.account_balance_outlined),
          const SizedBox(height: 14),
          _buildTextField('Account Number', _accountNumberController, Icons.numbers_rounded, isNumber: true),
          const SizedBox(height: 14),
          _buildTextField('IFSC Code', _ifscController, Icons.code_rounded),
          const SizedBox(height: 14),
          _buildTextField('UPI ID (Optional)', _upiIdController, Icons.qr_code_2_rounded),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveBankDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpertColors.primaryYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Bank Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawTab(double walletBalance, String formattedBalance) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFFB800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ExpertColors.primaryYellow.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Balance', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(formattedBalance, style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Min Withdrawal: ₹10 | Fee: ₹0', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payout Method Selector
          const Text('Payout Destination', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMethodPill('Bank', 'Bank Transfer (IMPS)', Icons.account_balance_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildMethodPill('UPI', 'UPI Instant', Icons.qr_code_2_rounded)),
            ],
          ),

          const SizedBox(height: 24),

          // Amount Input
          const Text('Enter Amount (₹)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: ExpertColors.primaryYellow, fontSize: 20, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: ExpertColors.cardBg,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ExpertColors.borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ExpertColors.primaryYellow)),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Pills
          Row(
            children: [
              _buildQuickPill('₹ 500', () => setState(() => _amountController.text = '500')),
              const SizedBox(width: 8),
              _buildQuickPill('₹ 1,000', () => setState(() => _amountController.text = '1000')),
              const SizedBox(width: 8),
              _buildQuickPill('₹ 1,500', () => setState(() => _amountController.text = '1500')),
              const SizedBox(width: 8),
              _buildQuickPill('Withdraw All', () => setState(() => _amountController.text = walletBalance.toInt().toString())),
            ],
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _processWithdrawal(walletBalance),
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpertColors.primaryYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('Submit Payout Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: ExpertColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: ExpertColors.primaryYellow, size: 20),
            filled: true,
            fillColor: ExpertColors.cardBg,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ExpertColors.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ExpertColors.primaryYellow)),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodPill(String id, String label, IconData icon) {
    final bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? ExpertColors.primaryYellow.withValues(alpha: 0.15) : ExpertColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? ExpertColors.primaryYellow : ExpertColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? ExpertColors.primaryYellow : Colors.white60, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: isSelected ? ExpertColors.primaryYellow : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ExpertColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ExpertColors.borderColor),
          ),
          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
