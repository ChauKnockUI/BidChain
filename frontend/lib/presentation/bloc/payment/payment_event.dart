abstract class PaymentEvent {}

class RequestDeposit extends PaymentEvent {
  final double amountVnd;
  RequestDeposit(this.amountVnd);
}

class RequestWithdraw extends PaymentEvent {
  final double amountVnd;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;

  RequestWithdraw({
    required this.amountVnd,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
  });
}

class LoadPaymentHistory extends PaymentEvent {}

class ResetPaymentState extends PaymentEvent {}
