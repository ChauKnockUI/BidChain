import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/category_model.dart';
import '../../data/models/create_auction_request.dart';
import '../entities/auction_entity.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<AuctionEntity>>> getAuctions();

  Future<Either<Failure, AuctionEntity>> getAuctionDetail(String auctionId);

  Future<Either<Failure, String>> createAuction(CreateAuctionRequest request);

  Future<Either<Failure, List<String>>> uploadImages(List<File> images);

  Future<Either<Failure, List<CategoryModel>>> getCategories();

  Future<Either<Failure, String>> placeBid({
    required String auctionId,
    required double amountVnd,
  });

  Future<Either<Failure, String>> endAuction(String auctionId);
  Future<Either<Failure, void>> confirmReceipt(String auctionId);
}
