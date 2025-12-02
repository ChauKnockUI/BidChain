import 'dart:io';
import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auction_model.dart';
import '../../models/category_model.dart';
import '../../models/create_auction_request.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionModel>> getAuctions();
  Future<AuctionModel> getAuctionDetail(String auctionId);
  Future<String> createAuction(CreateAuctionRequest request);
  Future<List<String>> uploadImages(List<File> images);
  Future<List<CategoryModel>> getCategories();
  Future<String> placeBid({
    required String auctionId,
    required double amountVnd,
  });
  Future<String> endAuction(String auctionId);
  Future<void> confirmReceipt(String auctionId);
}

class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final DioClient dioClient;

  AuctionRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AuctionModel>> getAuctions() async {
    try {
      final response = await dioClient.get(ApiConstants.getAuctions);

      if (response.statusCode == 200) {
        if (response.data is List) {
          final list = response.data as List;
          final auctions = <AuctionModel>[];
          for (var i = 0; i < list.length; i++) {
            try {
              final auction = AuctionModel.fromJson(list[i]);
              auctions.add(auction);
            } catch (e) {
              // Skip invalid auctions
            }
          }
          return auctions;
        } else if (response.data is Map && response.data['data'] is List) {
           final list = response.data['data'] as List;
           return list.map((e) => AuctionModel.fromJson(e)).toList();
        } else {
           throw ServerException(message: 'Invalid response format: Expected List but got ${response.data.runtimeType}');
        }
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
      final response = await dioClient.get(
        '${ApiConstants.getAuctionDetail}/$auctionId',
      );

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
  Future<String> createAuction(CreateAuctionRequest request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.createAuction,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final formData = FormData();
      for (var file in images) {
        formData.files.add(
          MapEntry('files', await MultipartFile.fromFile(file.path)),
        );
      }

      final response = await dioClient.post(
        ApiConstants.uploadImages,
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> urls = response.data['images'];
        print('✅ Upload successful: ${urls.length} URLs');
        return urls.map((e) => e.toString()).toList();
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to upload images',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dioClient.get(ApiConstants.getCategories);
      if (response.statusCode == 200) {
        final list = response.data['data'] as List;
        return list.map((e) => CategoryModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch categories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> placeBid({
    required String auctionId,
    required double amountVnd,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.placeBid,
        data: {'auction_id': auctionId, 'amount_vnd': amountVnd},
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

  @override
  Future<void> confirmReceipt(String auctionId) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.confirmReceipt}/$auctionId',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to confirm receipt',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
