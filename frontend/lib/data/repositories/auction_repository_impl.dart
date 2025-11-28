import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/remote/auction_remote_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource remoteDataSource;

  AuctionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AuctionEntity>>> getAuctions() async {
    try {
      final remoteAuctions = await remoteDataSource.getAuctions();
      return Right(remoteAuctions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuctionEntity>> getAuctionDetail(
    String auctionId,
  ) async {
    try {
      final remoteAuction = await remoteDataSource.getAuctionDetail(auctionId);
      return Right(remoteAuction);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createAuction({
    required String startingPriceWei,
    required int durationSeconds,
    required String metadataUrl,
  }) async {
    try {
      final auctionId = await remoteDataSource.createAuction(
        startingPriceWei: startingPriceWei,
        durationSeconds: durationSeconds,
        metadataUrl: metadataUrl,
      );
      return Right(auctionId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> placeBid({
    required String auctionId,
    required String amountWei,
  }) async {
    try {
      final txHash = await remoteDataSource.placeBid(
        auctionId: auctionId,
        amountWei: amountWei,
      );
      return Right(txHash);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> endAuction(String auctionId) async {
    try {
      final txHash = await remoteDataSource.endAuction(auctionId);
      return Right(txHash);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
