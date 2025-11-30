import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class PaymentRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<Map<String, dynamic>> createDepositRequest(double amountVnd) async {
    try {
      final response = await _dioClient.post(
        '/payment/deposit/request',
        data: {'amount_vnd': amountVnd},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to create deposit request',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createWithdrawRequest({
    required double amountVnd,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      final response = await _dioClient.post(
        '/payment/withdraw/request',
        data: {
          'amount_vnd': amountVnd,
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder_name': accountHolderName,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to create withdraw request',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getDepositHistory() async {
    try {
      final response = await _dioClient.get('/payment/deposit/history');
      return response.data['deposit_requests'] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to fetch deposit history',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getWithdrawHistory() async {
    try {
      final response = await _dioClient.get('/payment/withdraw/history');
      return response.data['withdraw_requests'] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to fetch withdraw history',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
