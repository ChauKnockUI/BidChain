import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auction_detail_repository.dart';
import 'auction_detail_event.dart';
import 'auction_detail_state.dart';

class AuctionDetailBloc extends Bloc<AuctionDetailEvent, AuctionDetailState> {
  final AuctionDetailRepository repository;

  AuctionDetailBloc({required this.repository})
    : super(const AuctionDetailInitial()) {
    on<LoadAuctionDetail>(_onLoadAuctionDetail);
    on<RefreshAuctionDetail>(_onRefreshAuctionDetail);
    on<PlaceBid>(_onPlaceBid);
    on<ConfirmReceiptEvent>(_onConfirmReceipt);
  }

  Future<void> _onLoadAuctionDetail(
    LoadAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    emit(const AuctionDetailLoading());

    final result = await repository.getAuctionDetail(event.auctionId);

    result.fold(
      (failure) => emit(AuctionDetailError(message: failure.message)),
      (auction) => emit(AuctionDetailLoaded(auction: auction)),
    );
  }

  Future<void> _onRefreshAuctionDetail(
    RefreshAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await repository.getAuctionDetail(event.auctionId);

    result.fold(
      (failure) => emit(AuctionDetailError(message: failure.message)),
      (auction) => emit(AuctionDetailLoaded(auction: auction)),
    );
  }

  Future<void> _onPlaceBid(
    PlaceBid event,
    Emitter<AuctionDetailState> emit,
  ) async {
    // Get current auction from state
    if (state is! AuctionDetailLoaded) return;

    final currentAuction = (state as AuctionDetailLoaded).auction;
    emit(BidPlacing(auction: currentAuction));

    final result = await repository.placeBid(
      auctionId: event.auctionId,
      amountVnd: event.amountVnd,
    );

    await result.fold(
      (failure) async {
        emit(BidError(auction: currentAuction, message: failure.message));
        // Return to loaded state after showing error
        await Future.delayed(const Duration(milliseconds: 100));
        emit(AuctionDetailLoaded(auction: currentAuction));
      },
      (_) async {
        // Bid successful, refresh auction data
        final refreshResult = await repository.getAuctionDetail(
          event.auctionId,
        );

        refreshResult.fold(
          (failure) => emit(AuctionDetailError(message: failure.message)),
          (updatedAuction) {
            emit(
              BidPlaced(
                auction: updatedAuction,
                message: 'Đặt giá thành công!',
              ),
            );
            // Return to loaded state after showing success
            Future.delayed(const Duration(seconds: 2), () {
              if (!emit.isDone) {
                emit(AuctionDetailLoaded(auction: updatedAuction));
              }
            });
          },
        );
      },
    );
  }

  Future<void> _onConfirmReceipt(
    ConfirmReceiptEvent event,
    Emitter<AuctionDetailState> emit,
  ) async {
    print(
      '🔴 BLOC: _onConfirmReceipt called with auctionId=${event.auctionId}',
    );
    print('🔴 BLOC: Current state = $state');

    if (state is! AuctionDetailLoaded) {
      print('🔴 BLOC: State is not AuctionDetailLoaded, returning');
      return;
    }

    final currentAuction = (state as AuctionDetailLoaded).auction;
    print('🔴 BLOC: Current auction status = ${currentAuction.status}');

    emit(ReceiptConfirming(auction: currentAuction));
    print('🔴 BLOC: Emitted ReceiptConfirming state');

    print('🔴 BLOC: Calling repository.confirmReceipt...');
    final result = await repository.confirmReceipt(event.auctionId);

    await result.fold(
      (failure) async {
        print('🔴 BLOC: confirmReceipt failed: ${failure.message}');
        emit(ReceiptError(auction: currentAuction, message: failure.message));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(AuctionDetailLoaded(auction: currentAuction));
      },
      (_) async {
        print('🔴 BLOC: confirmReceipt success, refreshing auction data...');
        // Refresh auction data
        final refreshResult = await repository.getAuctionDetail(
          event.auctionId,
        );
        refreshResult.fold(
          (failure) {
            print('🔴 BLOC: Refresh failed: ${failure.message}');
            emit(AuctionDetailError(message: failure.message));
          },
          (updatedAuction) {
            print(
              '🔴 BLOC: Refresh success, new status = ${updatedAuction.status}',
            );
            emit(
              ReceiptConfirmed(
                auction: updatedAuction,
                message: 'Xác nhận nhận hàng thành công!',
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (!emit.isDone) {
                emit(AuctionDetailLoaded(auction: updatedAuction));
              }
            });
          },
        );
      },
    );
  }
}
