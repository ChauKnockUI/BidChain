import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/auction_entity.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<AuctionEntity>>> getAuctions();

  Future<Either<Failure, AuctionEntity>> getAuctionDetail(String auctionId);

  Future<Either<Failure, String>> createAuction({
    required String startingPriceWei,
    required int durationSeconds,
    required String metadataUrl,
  });

  Future<Either<Failure, String>> placeBid({
    required String auctionId,
    required String amountWei,
  });

  Future<Either<Failure, String>> endAuction(String auctionId);
}