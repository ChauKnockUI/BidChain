import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/my_auction_model.dart';
import '../../models/my_bid_model.dart';

abstract class MyActivityRemoteDataSource {
  Future<List<MyAuctionModel>> getMyAuctions();
  Future<List<MyBidModel>> getMyBids();
}

class MyActivityRemoteDataSourceImpl implements MyActivityRemoteDataSource {
  final DioClient dioClient;

  MyActivityRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MyAuctionModel>> getMyAuctions() async {
    try {
      final response = await dioClient.get(ApiConstants.getUserAuctions);

      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((e) => MyAuctionModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch my auctions',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MyBidModel>> getMyBids() async {
    try {
      final response = await dioClient.get(ApiConstants.getUserBids);

      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((e) => MyBidModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch my bids',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
