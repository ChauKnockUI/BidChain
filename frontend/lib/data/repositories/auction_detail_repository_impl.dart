import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/auction_detail_entity.dart';
import '../../domain/repositories/auction_detail_repository.dart';
import '../datasources/remote/auction_detail_remote_datasource.dart';

class AuctionDetailRepositoryImpl implements AuctionDetailRepository {
  final AuctionDetailRemoteDataSource remoteDataSource;

  AuctionDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuctionDetailEntity>> getAuctionDetail(
    String auctionId,
  ) async {
    try {
      final auction = await remoteDataSource.getAuctionDetail(auctionId);
      return Right(auction);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> placeBid({
    required String auctionId,
    required double amountVnd,
  }) async {
    try {
      await remoteDataSource.placeBid(
        auctionId: auctionId,
        amountVnd: amountVnd,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmReceipt(String auctionId) async {
    try {
      await remoteDataSource.confirmReceipt(auctionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
