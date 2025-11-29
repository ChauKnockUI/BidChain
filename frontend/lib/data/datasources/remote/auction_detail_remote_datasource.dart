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
      final response = await dioClient.post(
        ApiConstants.placeBid,
        data: {'auctionId': auctionId, 'amountVnd': amountVnd},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to place bid',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
