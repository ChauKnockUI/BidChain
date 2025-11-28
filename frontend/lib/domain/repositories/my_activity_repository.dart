import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/my_auction_entity.dart';
import '../entities/my_bid_entity.dart';

abstract class MyActivityRepository {
  Future<Either<Failure, List<MyAuctionEntity>>> getMyAuctions();
  Future<Either<Failure, List<MyBidEntity>>> getMyBids();
}
