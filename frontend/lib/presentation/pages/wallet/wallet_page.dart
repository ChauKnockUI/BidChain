import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  double _balance = 0.0;
  bool _isWithdrawing = false;

  @override
  void initState() {
    super.initState();
    // TODO: fetch real balance via repository/usecase
    _balance = 1.234; // placeholder
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final to = _toController.text.trim();
    final amount = _amountController.text.trim();
    if (to.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provide address and amount')));
      return;
    }
    setState(() => _isWithdrawing = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate
    setState(() => _isWithdrawing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal simulated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 36, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 6),
                        Text('$_balance ETH', style: AppTextStyles.h3.copyWith(color: AppColors.black)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _toController,
              label: 'To address',
              hint: '0x...',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _amountController,
              label: 'Amount (ETH)',
              hint: '0.1',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Withdraw',
              isLoading: _isWithdrawing,
              onPressed: _withdraw,
            ),
          ],
        ),
      ),
    );
  }
}