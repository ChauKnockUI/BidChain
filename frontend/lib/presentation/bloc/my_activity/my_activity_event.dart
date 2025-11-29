import 'package:equatable/equatable.dart';

abstract class MyActivityEvent extends Equatable {
  const MyActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyAuctions extends MyActivityEvent {
  const LoadMyAuctions();
}

class LoadMyBids extends MyActivityEvent {
  const LoadMyBids();
}

class RefreshMyActivity extends MyActivityEvent {
  const RefreshMyActivity();
}
