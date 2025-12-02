import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auction_detail_model.dart';

abstract class AuctionDetailRemoteDataSource {
  Future<AuctionDetailModel> getAuctionDetail(String auctionId);
  Future<void> placeBid({required String auctionId, required double amountVnd});
  Future<void> confirmReceipt(String auctionId);
}

class AuctionDetailRemoteDataSourceImpl
    implements AuctionDetailRemoteDataSource {
  final DioClient dioClient;

  AuctionDetailRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuctionDetailModel> getAuctionDetail(String auctionId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.getAuctionDetail}/$auctionId',
      );

      if (response.statusCode == 200) {
        return AuctionDetailModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to fetch auction detail',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> placeBid({
    required String auctionId,
    required double amountVnd,
  }) async {
    try {
      print('Placing bid: Auction $auctionId, Amount $amountVnd VND');

      final response = await dioClient.post(
        ApiConstants.placeBid,
        data: {'auction_id': auctionId, 'amount_vnd': amountVnd},
      );

      print('Bid response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorMsg = response.data['error'] ?? 'Failed to place bid';
        print('Bid failed: $errorMsg');
        throw ServerException(message: errorMsg);
      }
    } catch (e) {
      print('Bid error: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> confirmReceipt(String auctionId) async {
    try {
      print('🔵 CONFIRM RECEIPT: Starting for auction $auctionId');
      print(
        '🔵 CONFIRM RECEIPT: URL = ${ApiConstants.confirmReceipt}/$auctionId',
      );

      final response = await dioClient.post(
        '${ApiConstants.confirmReceipt}/$auctionId',
      );

      print('🔵 CONFIRM RECEIPT: Response status = ${response.statusCode}');
      print('🔵 CONFIRM RECEIPT: Response data = ${response.data}');

      if (response.statusCode != 200) {
        print('❌ CONFIRM RECEIPT: Failed with status ${response.statusCode}');
        throw ServerException(
          message: response.data['error'] ?? 'Failed to confirm receipt',
        );
      }

      print('✅ CONFIRM RECEIPT: Success');
    } catch (e) {
      print('❌ CONFIRM RECEIPT: Exception = $e');
      throw ServerException(message: e.toString());
    }
  }
}
