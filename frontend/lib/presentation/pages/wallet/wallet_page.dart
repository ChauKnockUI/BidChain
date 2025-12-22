import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/custom_toast.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_event.dart';
import '../../bloc/payment/payment_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load history when entering
    context.read<PaymentBloc>().add(LoadPaymentHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const double ethToVndRate = 50000000; // 1 ETH = 50,000,000 VND

  // Convert ETH → VND
  static double ethToVnd(double eth) {
    return eth * ethToVndRate;
  }

  // Format VND: 1000000 → "1.000.000 VND"
  static String formatVnd(dynamic vnd) {
    final f = NumberFormat("#,###", "vi_VN");
    return "${f.format(vnd)} VND";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is DepositSuccess) {
          // Show success dialog with QR
          _showDepositSuccessDialog(state);
          // Refresh user balance immediately
          context.read<AuthBloc>().add(const AuthCheckStatusEvent());
          // Refresh transaction history
          context.read<PaymentBloc>().add(LoadPaymentHistory());
        } else if (state is WithdrawSuccess) {
          Toast.show(context, message: state.message, type: ToastType.success);
          // Refresh user data
          context.read<AuthBloc>().add(const AuthCheckStatusEvent());
          // Refresh history
          context.read<PaymentBloc>().add(LoadPaymentHistory());
        } else if (state is PaymentFailure) {
          Toast.show(context, message: state.error, type: ToastType.error);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccessState) {
            final user = authState.user;
            final availableEth = user.balanceEth - user.lockedEth;

            return Scaffold(
              backgroundColor: AppColors.secondary,
              appBar: AppBar(
                title: Text(
                  'My Wallet',
                  style: AppTextStyles.h2.copyWith(color: AppColors.black),
                ),
                backgroundColor: AppColors.white,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(color: AppColors.black),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  context.read<AuthBloc>().add(const AuthCheckStatusEvent());
                  context.read<PaymentBloc>().add(LoadPaymentHistory());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Card
                      _buildBalanceCard(
                        user.balanceEth,
                        user.lockedEth,
                        availableEth,
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      _buildActionButtons(context, availableEth),
                      const SizedBox(height: 24),

                      // Transaction History
                      Text(
                        'Transaction History',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTransactionHistory(),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double total, double locked, double available) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatVnd(ethToVnd(total)),
            style: AppTextStyles.h1.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVnd(ethToVnd(available)),
                      style: AppTextStyles.h4.copyWith(color: AppColors.black),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.black.withOpacity(0.2),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Locked',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVnd(ethToVnd(locked)),
                      style: AppTextStyles.h4.copyWith(color: AppColors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double availableEth) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            title: 'Deposit',
            icon: Icons.add_circle_outline,
            onPress: () => _showDepositModal(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SecondaryButton(
            title: 'Withdraw',
            icon: Icons.remove_circle_outline,
            onPress: () => _showWithdrawModal(context, availableEth),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color.fromARGB(255, 0, 0, 0),
            unselectedLabelColor: AppColors.grey,
            indicatorColor: const Color.fromARGB(255, 63, 0, 0),
            tabs: const [
              Tab(text: 'Deposits'),
              Tab(text: 'Withdrawals'),
            ],
          ),
          Expanded(
            child: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentHistoryLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHistoryList(state.deposits, isDeposit: true),
                      _buildHistoryList(state.withdrawals, isDeposit: false),
                    ],
                  );
                } else if (state is PaymentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text('No history loaded'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<dynamic> items, {required bool isDeposit}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryItem(item, isDeposit: isDeposit);
      },
    );
  }

  Widget _buildHistoryItem(dynamic item, {required bool isDeposit}) {
    // Adapt based on your actual data structure
    final amount = isDeposit
        ? (item['amount_vnd'] ?? 0)
        : (item['amount_vnd'] ?? 0);
    final status = isDeposit
        ? (item['status'] ?? 'UNKNOWN')
        : (item['status'] ?? 'UNKNOWN');
    final dateStr = isDeposit
        ? (item['created_at'] ?? '')
        : (item['created_at']?.toString() ?? '');

    DateTime? date;
    try {
      if (dateStr is String && dateStr.isNotEmpty) {
        date = DateTime.parse(dateStr);
      }
    } catch (_) {}

    Color statusColor = AppColors.grey;
    if (status == 'SUCCESS' || status == 'COMPLETED' || status == 'PAID_DONE') {
      statusColor = AppColors.success;
    } else if (status == 'PENDING' ||
        status == 'PENDING_PAYMENT' ||
        status == 'PAID')
      statusColor = AppColors.warning;
    else if (status == 'FAILED' || status == 'REJECTED' || status == 'TIMEOUT')
      statusColor = AppColors.error;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isDeposit
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        child: Icon(
          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isDeposit ? AppColors.success : AppColors.warning,
          size: 20,
        ),
      ),
      title: Text(
        isDeposit ? 'Deposit' : 'Withdrawal',
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        date != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(date)
            : 'Unknown date',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isDeposit ? '+' : '-'}${formatVnd(double.parse(amount.toString()))}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDeposit ? AppColors.success : AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODALS (Copied and adapted from ProfilePage)
  // ===========================================================================

  void _showDepositModal(BuildContext context) {
    String amount = '';
    String errorText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deposit Funds',
                  style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter amount in VND to deposit via MoMo.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                FormInput(
                  label: 'Amount (VND)',
                  value: amount,
                  hint: 'Min 10,000 VND',
                  keyboardType: TextInputType.number,
                  error: errorText,
                  prefixIcon: Icons.attach_money,
                  onChangeText: (val) {
                    setModalState(() {
                      amount = val;
                      errorText = '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  title: 'Continue to Payment',
                  onPress: () {
                    final amountVal = double.tryParse(amount) ?? 0;
                    if (amountVal < 10000) {
                      setModalState(
                        () => errorText = 'Minimum deposit is 10,000 VND',
                      );
                      return;
                    }
                    if (amountVal > 50000000) {
                      setModalState(
                        () => errorText = 'Maximum deposit is 50,000,000 VND',
                      );
                      return;
                    }
                    Navigator.pop(context); // Close input modal
                    context.read<PaymentBloc>().add(RequestDeposit(amountVal));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWithdrawModal(BuildContext context, double availableEth) {
    String amount = '';
    String bankName = '';
    String accountNum = '';
    String accountName = '';
    String amountError = '';
    String bankError = '';
    String numError = '';
    String nameError = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdraw Funds',
                    style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available: ${availableEth.toStringAsFixed(4)} ETH',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormInput(
                    label: 'Amount (VND)',
                    value: amount,
                    hint: 'Min 50,000 VND',
                    keyboardType: TextInputType.number,
                    error: amountError,
                    prefixIcon: Icons.attach_money,
                    onChangeText: (val) => setModalState(() {
                      amount = val;
                      amountError = '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  FormInput(
                    label: 'Bank Name',
                    value: bankName,
                    hint: 'e.g. Vietcombank',
                    error: bankError,
                    prefixIcon: Icons.account_balance,
                    onChangeText: (val) => setModalState(() {
                      bankName = val;
                      bankError = '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  FormInput(
                    label: 'Account Number',
                    value: accountNum,
                    hint: 'e.g. 1234567890',
                    keyboardType: TextInputType.number,
                    error: numError,
                    prefixIcon: Icons.numbers,
                    onChangeText: (val) => setModalState(() {
                      accountNum = val;
                      numError = '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  FormInput(
                    label: 'Account Holder Name',
                    value: accountName,
                    hint: 'e.g. NGUYEN VAN A',
                    error: nameError,
                    prefixIcon: Icons.person,
                    onChangeText: (val) => setModalState(() {
                      accountName = val;
                      nameError = '';
                    }),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    title: 'Submit Request',
                    onPress: () {
                      bool isValid = true;
                      final amountVal = double.tryParse(amount) ?? 0;
                      if (amountVal < 50000) {
                        setModalState(() => amountError = 'Min 50,000 VND');
                        isValid = false;
                      }
                      // Simple check: 1 ETH approx 50M VND (client side check only)
                      if ((amountVal / 50000000) > availableEth) {
                        setModalState(
                          () => amountError = 'Insufficient balance (approx)',
                        );
                        isValid = false;
                      }
                      if (bankName.isEmpty) {
                        setModalState(() => bankError = 'Required');
                        isValid = false;
                      }
                      if (accountNum.isEmpty) {
                        setModalState(() => numError = 'Required');
                        isValid = false;
                      }
                      if (accountName.isEmpty) {
                        setModalState(() => nameError = 'Required');
                        isValid = false;
                      }

                      if (!isValid) return;

                      Navigator.pop(context);
                      context.read<PaymentBloc>().add(
                        RequestWithdraw(
                          amountVnd: amountVal,
                          bankName: bankName,
                          accountNumber: accountNum,
                          accountHolderName: accountName,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDepositSuccessDialog(DepositSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Payment Required',
          style: AppTextStyles.h3.copyWith(color: AppColors.accent),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan QR Code with MoMo', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: state.qrCodeUrl.isNotEmpty
                    ? Center(
                        child: QrImageView(
                          data: state.qrCodeUrl,
                          version: QrVersions.auto,
                          size: 180.0,
                          backgroundColor: Colors.white,
                        ),
                      )
                    : const Center(child: Text('QR Error')),
              ),
              const SizedBox(height: 16),
              Text(
                'Amount: ${formatVnd(state.amountVnd)}',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 8),
              Text(
                'System will automatically update your balance after payment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthCheckStatusEvent());
              context.read<PaymentBloc>().add(LoadPaymentHistory());
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
