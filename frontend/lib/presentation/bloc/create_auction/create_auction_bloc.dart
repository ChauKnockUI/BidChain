import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/create_auction_request.dart';
import '../../../../domain/usecases/create_auction_usecase.dart';

// Events
abstract class CreateAuctionEvent {}

class LoadCategoriesEvent extends CreateAuctionEvent {}

class UploadImagesEvent extends CreateAuctionEvent {
  final List<File> images;
  UploadImagesEvent(this.images);
}

class SubmitAuctionEvent extends CreateAuctionEvent {
  final CreateAuctionRequest request;
  SubmitAuctionEvent(this.request);
}

// States
abstract class CreateAuctionState {}

class CreateAuctionInitial extends CreateAuctionState {}

class CreateAuctionLoading extends CreateAuctionState {}

class CategoriesLoaded extends CreateAuctionState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class ImagesUploaded extends CreateAuctionState {
  final List<String> imageUrls;
  ImagesUploaded(this.imageUrls);
}

class CreateAuctionSuccess extends CreateAuctionState {
  final String auctionId;
  CreateAuctionSuccess(this.auctionId);
}

class CreateAuctionFailure extends CreateAuctionState {
  final String message;
  CreateAuctionFailure(this.message);
}

// Bloc
class CreateAuctionBloc extends Bloc<CreateAuctionEvent, CreateAuctionState> {
  final CreateAuctionUseCase createAuctionUseCase;

  CreateAuctionBloc({required this.createAuctionUseCase}) : super(CreateAuctionInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<UploadImagesEvent>(_onUploadImages);
    on<SubmitAuctionEvent>(_onSubmitAuction);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CreateAuctionState> emit,
  ) async {
    print('🚀 LoadCategoriesEvent received');
    emit(CreateAuctionLoading());
    print('⏳ Calling getCategories API...');
    final result = await createAuctionUseCase.getCategories();
    result.fold(
      (failure) {
        print('❌ Failed to load categories: ${failure.message}');
        emit(CreateAuctionFailure(failure.message));
      },
      (categories) {
        print('✅ Categories loaded successfully: ${categories.length} items');
        for (var cat in categories) {
          print('   - ${cat.name} (${cat.id})');
        }
        emit(CategoriesLoaded(categories));
      },
    );
  }

  Future<void> _onUploadImages(
    UploadImagesEvent event,
    Emitter<CreateAuctionState> emit,
  ) async {
    emit(CreateAuctionLoading());
    final result = await createAuctionUseCase.uploadImages(event.images);
    result.fold(
      (failure) => emit(CreateAuctionFailure(failure.message)),
      (imageUrls) => emit(ImagesUploaded(imageUrls)),
    );
  }

  Future<void> _onSubmitAuction(
    SubmitAuctionEvent event,
    Emitter<CreateAuctionState> emit,
  ) async {
    emit(CreateAuctionLoading());
    final result = await createAuctionUseCase.createAuction(event.request);
    result.fold(
      (failure) => emit(CreateAuctionFailure(failure.message)),
      (auctionId) => emit(CreateAuctionSuccess(auctionId)),
    );
  }
}
