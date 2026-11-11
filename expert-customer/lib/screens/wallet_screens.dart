import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/screens/transactions_screen.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Wallet Home Screen
class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final balance = double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMoneyScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
                boxShadow: isLight ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Balance', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey)),
                      const SizedBox(height: 5),
                      Text('₹ ${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet, size: 60, color: AppTheme.primary),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Recharge & Get More', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildRechargePack(context, 50, '+5% Bonus'),
                _buildRechargePack(context, 100, '+10% Bonus'),
                _buildRechargePack(context, 200, '+15% Bonus'),
                _buildRechargePack(context, 500, '+20% Bonus', isPopular: true),
                _buildRechargePack(context, 1000, '+25% Bonus'),
                _buildRechargePack(context, 2000, '+30% Bonus'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('View Transactions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargePack(BuildContext context, double amount, String bonus, {bool isPopular = false}) {
    final priceStr = '₹${amount.toInt()}';
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return GestureDetector(
      onTap: () {
        _startRazorpayRecharge(context, amount);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
              boxShadow: isLight ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(priceStr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 5),
                Text(bonus, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }
}

// Add Money Screen
class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _controller = TextEditingController();

  void _proceed() {
    final double amount = double.tryParse(_controller.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    _startRazorpayRecharge(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Add Money')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Deposit Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [100, 500, 1000].map((amt) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = amt.toString();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: textColor,
                    elevation: isLight ? 1 : 0,
                  ),
                  child: Text('+ ₹$amt'),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Proceed to Payment Packs', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recharge Packs
class RechargePacksScreen extends StatelessWidget {
  const RechargePacksScreen({super.key});

  final List<Map<String, dynamic>> _packs = const [
    {'name': 'Silver Pack', 'desc': 'Get 10% Extra Balance', 'price': 250, 'bonus': '₹25 Bonus'},
    {'name': 'Gold Pack', 'desc': 'Get 15% Extra Balance', 'price': 500, 'bonus': '₹75 Bonus'},
    {'name': 'Platinum Pack', 'desc': 'Get 20% Extra Balance', 'price': 1000, 'bonus': '₹200 Bonus'},
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Recharge Packs')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a Pack for Extra Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _packs.length,
                itemBuilder: (context, index) {
                  final pack = _packs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pack['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 4),
                            Text(pack['desc'], style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(pack['bonus'], style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final double amount = double.tryParse(pack['price'].toString()) ?? 0.0;
                            showRazorpaySimulator(
                              context: context,
                              amount: amount,
                              onSuccess: () async {
                                final success = await Provider.of<AuthProvider>(context, listen: false).rechargeWallet(amount);
                                if (success && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PaymentSuccessScreen(amount: amount)),
                                  );
                                }
                              },
                              onFailure: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Payment failed or cancelled.')),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                          child: Text('₹${pack['price']}'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  const PaymentSuccessScreen({super.key, this.amount = 0.0});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: AppTheme.accent,
                child: Icon(Icons.check, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 25),
              Text('Payment Successful', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),
              Text(
                '₹${amount.toStringAsFixed(2)} has been credited to your wallet balance successfully.',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Razorpay Simulator Helper Function
void showRazorpaySimulator({
  required BuildContext context,
  required double amount,
  required VoidCallback onSuccess,
  required VoidCallback onFailure,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RazorpaySimulatorSheet(
      amount: amount,
      onSuccess: onSuccess,
      onFailure: onFailure,
    ),
  );
}

void _startRazorpayRecharge(BuildContext context, double amount) async {
  void openFallbackSimulator() {
    showRazorpaySimulator(
      context: context,
      amount: amount,
      onSuccess: () async {
        final success = await Provider.of<AuthProvider>(context, listen: false).rechargeWallet(amount);
        if (success && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentSuccessScreen(amount: amount)),
          );
        }
      },
      onFailure: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed or cancelled.')),
        );
      },
    );
  }

  if (kIsWeb) {
    openFallbackSimulator();
  } else {
    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user ?? {};
      final userEmail = user['email'] ?? 'customer@example.com';
      final userMobile = user['mobileNumber'] ?? '9999999999';

      // 1. Create order on backend
      final orderData = await apiService.createRazorpayOrder(amount);
      if (orderData == null || orderData['id'] == null) {
        openFallbackSimulator();
        return;
      }
      final String orderId = orderData['id'];

      // 2. Initialize Razorpay SDK
      final razorpay = Razorpay();
      
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
        final success = await authProvider.verifyAndRechargeWallet(
          orderId: orderId,
          paymentId: response.paymentId ?? '',
          signature: response.signature ?? '',
          amount: amount,
        );
        if (!context.mounted) return;
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentSuccessScreen(amount: amount)),
          );
        } else {
          openFallbackSimulator();
        }
        razorpay.clear();
      });

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        openFallbackSimulator();
        razorpay.clear();
      });

      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        openFallbackSimulator();
        razorpay.clear();
      });

      // 3. Open Razorpay checkout options
      var options = {
        'key': AppConstants.razorpayKeyId,
        'amount': (amount * 100).toInt(),
        'name': 'Expert Consultation App',
        'description': 'Wallet Top-up',
        'order_id': orderId,
        'prefill': {
          'contact': userMobile,
          'email': userEmail,
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      razorpay.open(options);
    } catch (e) {
      if (context.mounted) {
        openFallbackSimulator();
      }
    }
  }
}

// Razorpay Simulator Sheet Widget
class RazorpaySimulatorSheet extends StatefulWidget {
  final double amount;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const RazorpaySimulatorSheet({
    super.key,
    required this.amount,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<RazorpaySimulatorSheet> createState() => _RazorpaySimulatorSheetState();
}

class _RazorpaySimulatorSheetState extends State<RazorpaySimulatorSheet> {
  bool _isProcessing = false;
  String? _selectedMethod;

  void _handlePayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment loading
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      // Show mock Success/Failure dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Razorpay Test Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Simulate payment for ₹${widget.amount.toStringAsFixed(2)}:',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // Close dialog
                Navigator.pop(context); // Close sheet
                widget.onFailure();
              },
              child: const Text('Fail', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // Close dialog
                Navigator.pop(context); // Close sheet
                widget.onSuccess();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Succeed', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF18191E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Razorpay',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TEST MODE',
                          style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Expert Portal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Amount to Pay', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                    '₹ ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white10),
          const SizedBox(height: 15),

          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text('Connecting to gateway...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else ...[
            const Text(
              'PAYMENT OPTIONS',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildOptionRow(
              method: 'card',
              icon: Icons.credit_card,
              title: 'Card',
              subtitle: 'Visa, Mastercard, RuPay',
            ),
            const SizedBox(height: 10),
            _buildOptionRow(
              method: 'upi',
              icon: Icons.phone_android,
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, Paytm',
            ),
            const SizedBox(height: 10),
            _buildOptionRow(
              method: 'netbanking',
              icon: Icons.account_balance,
              title: 'Netbanking',
              subtitle: 'All major Indian banks',
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Pay ₹ ${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required String method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F62FE).withValues(alpha: 0.08) : const Color(0xFF22242C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F62FE) : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0F62FE) : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _selectedMethod,
              activeColor: const Color(0xFF0F62FE),
              onChanged: (val) {
                setState(() {
                  _selectedMethod = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
