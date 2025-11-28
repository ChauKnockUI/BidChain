import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../data/datasources/remote/auction_remote_datasource.dart';
import '../../data/repositories/auction_repository_impl.dart';
import '../../domain/repositories/auction_repository.dart';
import '../../domain/usecases/create_auction_usecase.dart';
import '../../presentation/bloc/create_auction/create_auction_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late DioClient _dioClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late AuthRepository _authRepository;
  static late LoginUseCase _loginUseCase;
  static late RegisterUseCase _registerUseCase;
  
  // Auction dependencies
  static late AuctionRemoteDataSource _auctionRemoteDataSource;
  static late AuctionRepository _auctionRepository;
  static late CreateAuctionUseCase _createAuctionUseCase;
  static late NetworkInfo _networkInfo;

  /// Initialize all dependencies - call this in main() before running the app
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _dioClient = DioClient();
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_dioClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(_sharedPreferences);
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);

    _networkInfo = NetworkInfoImpl(InternetConnectionChecker.instance);
    _auctionRemoteDataSource = AuctionRemoteDataSourceImpl(_dioClient);
    _auctionRepository = AuctionRepositoryImpl(
      remoteDataSource: _auctionRemoteDataSource,
      networkInfo: _networkInfo,
    );
    _createAuctionUseCase = CreateAuctionUseCase(_auctionRepository);
  }

  // Getters
  static AuthBloc getAuthBloc() => AuthBloc(
    loginUseCase: _loginUseCase,
    registerUseCase: _registerUseCase,
  );

  static AuthRepository getAuthRepository() => _authRepository;
  static LoginUseCase getLoginUseCase() => _loginUseCase;
  static RegisterUseCase getRegisterUseCase() => _registerUseCase;

  static CreateAuctionBloc getCreateAuctionBloc() => CreateAuctionBloc(
    createAuctionUseCase: _createAuctionUseCase,
  );
}
