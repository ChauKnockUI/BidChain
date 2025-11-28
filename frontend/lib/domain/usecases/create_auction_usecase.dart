import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../data/models/category_model.dart';
import '../../data/models/create_auction_request.dart';
import '../repositories/auction_repository.dart';

class CreateAuctionUseCase {
  final AuctionRepository repository;

  CreateAuctionUseCase(this.repository);

  Future<Either<Failure, String>> createAuction(CreateAuctionRequest request) {
    return repository.createAuction(request);
  }

  Future<Either<Failure, List<String>>> uploadImages(List<File> images) {
    return repository.uploadImages(images);
  }

  Future<Either<Failure, List<CategoryModel>>> getCategories() {
    return repository.getCategories();
  }
}
