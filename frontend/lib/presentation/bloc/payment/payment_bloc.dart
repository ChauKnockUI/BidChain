import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<RequestDeposit>(_onRequestDeposit);
    on<RequestWithdraw>(_onRequestWithdraw);
    on<ResetPaymentState>((event, emit) => emit(PaymentInitial()));
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
  }

  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistory event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final deposits = await _paymentRepository.getDepositHistory();
      final withdrawals = await _paymentRepository.getWithdrawHistory();
      emit(PaymentHistoryLoaded(deposits: deposits, withdrawals: withdrawals));
    } catch (e) {
      emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRequestDeposit(
    RequestDeposit event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final result = await _paymentRepository.createDepositRequest(
        event.amountVnd,
      );

      print('PaymentBloc: Received Deposit Result: $result');
      final qrUrl = result['momo_payment']['qrCodeUrl'];
      print('PaymentBloc: QR Code URL: $qrUrl');

      emit(
        DepositSuccess(
          payUrl: result['momo_payment']['payUrl'],
          qrCodeUrl: qrUrl,
          message: result['message'],
          amountVnd: event.amountVnd,
        ),
      );
    } catch (e) {
      emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRequestWithdraw(
    RequestWithdraw event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final result = await _paymentRepository.createWithdrawRequest(
        amountVnd: event.amountVnd,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        accountHolderName: event.accountHolderName,
      );

      emit(
        WithdrawSuccess(
          message: result['message'],
          remainingBalanceEth:
              double.tryParse(result['remaining_balance_eth'].toString()) ??
              0.0,
        ),
      );
    } catch (e) {
      emit(PaymentFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
