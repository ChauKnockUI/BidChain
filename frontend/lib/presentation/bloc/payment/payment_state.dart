abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class DepositSuccess extends PaymentState {
  final String payUrl;
  final String qrCodeUrl;
  final String message;
  final double amountVnd;

  DepositSuccess({
    required this.payUrl,
    required this.qrCodeUrl,
    required this.message,
    required this.amountVnd,
  });
}

class WithdrawSuccess extends PaymentState {
  final String message;
  final double remainingBalanceEth;

  WithdrawSuccess({required this.message, required this.remainingBalanceEth});
}

class PaymentHistoryLoaded extends PaymentState {
  final List<dynamic> deposits;
  final List<dynamic> withdrawals;

  PaymentHistoryLoaded({required this.deposits, required this.withdrawals});
}

class PaymentFailure extends PaymentState {
  final String error;
  PaymentFailure(this.error);
}
