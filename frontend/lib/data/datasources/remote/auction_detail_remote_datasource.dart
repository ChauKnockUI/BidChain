import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auction_detail_model.dart';

abstract class AuctionDetailRemoteDataSource {
  Future<AuctionDetailModel> getAuctionDetail(String auctionId);
  Future<void> placeBid({required String auctionId, required double amountVnd});
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
        data: {
          'auction_id': auctionId, // ✅ Fixed: snake_case
          'amount_vnd': amountVnd, // ✅ Fixed: snake_case
        },
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
}
