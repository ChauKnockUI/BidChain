import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auction_model.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionModel>> getAuctions();
  Future<AuctionModel> getAuctionDetail(String auctionId);
  Future<String> createAuction({
    required String startingPriceWei,
    required int durationSeconds,
    required String metadataUrl,
  });
  Future<String> placeBid({
    required String auctionId,
    required String amountWei,
  });
  Future<String> endAuction(String auctionId);
}

class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final DioClient dioClient;

  AuctionRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AuctionModel>> getAuctions() async {
    try {
      final response = await dioClient.get(ApiConstants.getAuctions);

      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((e) => AuctionModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch auctions',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuctionModel> getAuctionDetail(String auctionId) async {
    try {
      final response = await dioClient.get('${ApiConstants.getAuctionDetail}/$auctionId');

      if (response.statusCode == 200) {
        return AuctionModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to fetch auction',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createAuction({
    required String startingPriceWei,
    required int durationSeconds,
    required String metadataUrl,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.createAuction,
        data: {
          'startingPriceWei': startingPriceWei,
          'durationSeconds': durationSeconds,
          'metadataUrl': metadataUrl,
        },
      );

      if (response.statusCode == 200) {
        return response.data['auctionId']?.toString() ?? '';
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to create auction',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> placeBid({
    required String auctionId,
    required String amountWei,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.placeBid,
        data: {
          'auctionId': auctionId,
          'amountWei': amountWei,
        },
      );

      if (response.statusCode == 200) {
        return response.data['txHash'] ?? '';
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to place bid',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> endAuction(String auctionId) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.endAuction}/$auctionId/end',
      );

      if (response.statusCode == 200) {
        return response.data['txHash'] ?? '';
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to end auction',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}