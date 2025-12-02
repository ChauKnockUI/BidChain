import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/auction_detail_entity.dart';

abstract class AuctionDetailRepository {
  Future<Either<Failure, AuctionDetailEntity>> getAuctionDetail(
    String auctionId,
  );
  Future<Either<Failure, void>> placeBid({
    required String auctionId,
    required double amountVnd,
  });
  Future<Either<Failure, void>> confirmReceipt(String auctionId);
}
