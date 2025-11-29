import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/my_auction_entity.dart';
import '../../domain/entities/my_bid_entity.dart';
import '../../domain/repositories/my_activity_repository.dart';
import '../datasources/remote/my_activity_remote_datasource.dart';

class MyActivityRepositoryImpl implements MyActivityRepository {
  final MyActivityRemoteDataSource remoteDataSource;

  MyActivityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MyAuctionEntity>>> getMyAuctions() async {
    try {
      final auctions = await remoteDataSource.getMyAuctions();
      return Right(auctions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MyBidEntity>>> getMyBids() async {
    try {
      final bids = await remoteDataSource.getMyBids();
      return Right(bids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
