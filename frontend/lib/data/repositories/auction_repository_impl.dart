import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/remote/auction_remote_datasource.dart';
import '../models/category_model.dart';
import '../models/create_auction_request.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuctionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AuctionEntity>>> getAuctions() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuctions = await remoteDataSource.getAuctions();
        return Right(remoteAuctions);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, AuctionEntity>> getAuctionDetail(
    String auctionId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuction = await remoteDataSource.getAuctionDetail(
          auctionId,
        );
        return Right(remoteAuction);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> createAuction(
    CreateAuctionRequest request,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final auctionId = await remoteDataSource.createAuction(request);
        return Right(auctionId);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<File> images) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrls = await remoteDataSource.uploadImages(images);
        return Right(imageUrls);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> placeBid({
    required String auctionId,
    required double amountVnd,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final txHash = await remoteDataSource.placeBid(
          auctionId: auctionId,
          amountVnd: amountVnd,
        );
        return Right(txHash);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> endAuction(String auctionId) async {
    if (await networkInfo.isConnected) {
      try {
        final txHash = await remoteDataSource.endAuction(auctionId);
        return Right(txHash);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, void>> confirmReceipt(String auctionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.confirmReceipt(auctionId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection"));
    }
  }
}
