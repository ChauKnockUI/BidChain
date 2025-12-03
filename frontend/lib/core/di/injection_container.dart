import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/my_activity_remote_datasource.dart';
import '../../data/datasources/remote/auction_detail_remote_datasource.dart';
import '../../data/datasources/remote/auction_remote_datasource.dart';
import '../../data/datasources/remote/category_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/my_activity_repository_impl.dart';
import '../../data/repositories/auction_detail_repository_impl.dart';
import '../../data/repositories/auction_repository_impl.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/repositories/auction_repository.dart';
import '../../domain/usecases/create_auction_usecase.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/my_activity_repository.dart';
import '../../domain/repositories/auction_detail_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/change_password_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/my_activity/my_activity_bloc.dart';
import '../../presentation/bloc/auction_detail/auction_detail_bloc.dart';
import '../../presentation/bloc/auction_list/auction_list_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../presentation/bloc/create_auction/create_auction_bloc.dart';
import '../../presentation/bloc/auction/auction_bloc.dart';
import '../../presentation/bloc/category/category_bloc.dart';
import '../../presentation/bloc/notification/notification_bloc.dart';
import '../../data/repositories/payment_repository.dart';
import '../../presentation/bloc/payment/payment_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/socket_service.dart';
import '../../presentation/bloc/chat/chat_bloc.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late DioClient _dioClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late AuthRepository _authRepository;
  static late LoginUseCase _loginUseCase;
  static late RegisterUseCase _registerUseCase;
  static late UpdateProfileUseCase _updateProfileUseCase;
  static late ChangePasswordUseCase _changePasswordUseCase;
  static late LogoutUseCase _logoutUseCase;

  // User dependencies
  static late UserRemoteDataSource _userRemoteDataSource;
  static late UserRepository _userRepository;

  // MyActivity dependencies
  static late MyActivityRemoteDataSource _myActivityRemoteDataSource;
  static late MyActivityRepository _myActivityRepository;

  // AuctionDetail dependencies
  static late AuctionDetailRemoteDataSource _auctionDetailRemoteDataSource;
  static late AuctionDetailRepository _auctionDetailRepository;

  // Auction dependencies
  static late AuctionRemoteDataSource _auctionRemoteDataSource;
  static late AuctionRepository _auctionRepository;

  static late CreateAuctionUseCase _createAuctionUseCase;
  static late NetworkInfo _networkInfo;

  // Category dependencies
  static late CategoryRemoteDataSource _categoryRemoteDataSource;
  static late CategoryRepository _categoryRepository;
  static late GetCategoriesUseCase _getCategoriesUseCase;

  // Payment dependencies
  static late PaymentRepository _paymentRepository;

  // Chat dependencies
  static late GeminiService _geminiService;
  static late ChatBloc _chatBloc;

  // Socket dependencies
  static late SocketService _socketService;

  // Location dependencies
  static late LocationService _locationService;

  // Notification dependencies
  static late NotificationRepository _notificationRepository;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _dioClient = DioClient();

    // Auth
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_dioClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(_sharedPreferences);
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);
    _updateProfileUseCase = UpdateProfileUseCase(_authRepository);
    _changePasswordUseCase = ChangePasswordUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);

    // User
    _userRemoteDataSource = UserRemoteDataSourceImpl(_dioClient);
    _userRepository = UserRepository(_userRemoteDataSource);

    // MyActivity
    _myActivityRemoteDataSource = MyActivityRemoteDataSourceImpl(_dioClient);
    _myActivityRepository = MyActivityRepositoryImpl(
      _myActivityRemoteDataSource,
    );

    // AuctionDetail
    _auctionDetailRemoteDataSource = AuctionDetailRemoteDataSourceImpl(
      _dioClient,
    );
    _auctionDetailRepository = AuctionDetailRepositoryImpl(
      _auctionDetailRemoteDataSource,
    );

    _networkInfo = NetworkInfoImpl(InternetConnectionChecker.instance);
    _auctionRemoteDataSource = AuctionRemoteDataSourceImpl(_dioClient);
    _auctionRepository = AuctionRepositoryImpl(
      remoteDataSource: _auctionRemoteDataSource,
      networkInfo: _networkInfo,
    );
    _createAuctionUseCase = CreateAuctionUseCase(_auctionRepository);

    // Payment
    _paymentRepository = PaymentRepository(_dioClient);

    // Category
    _categoryRemoteDataSource = CategoryRemoteDataSourceImpl(
      dioClient: _dioClient,
    );
    _categoryRepository = CategoryRepositoryImpl(
      remoteDataSource: _categoryRemoteDataSource,
    );
    _getCategoriesUseCase = GetCategoriesUseCase(_categoryRepository);

    // Chat
    _geminiService = GeminiService();
    _chatBloc = ChatBloc(geminiService: _geminiService);

    // Socket
    _socketService = SocketService();

    // Location
    _locationService = LocationService(dioClient: _dioClient);

    // Notification
    _notificationRepository = NotificationRepositoryImpl();
  }

  static MyActivityBloc getMyActivityBloc() =>
      MyActivityBloc(repository: _myActivityRepository);

  static MyActivityRepository getMyActivityRepository() =>
      _myActivityRepository;

  static AuctionDetailBloc getAuctionDetailBloc() =>
      AuctionDetailBloc(repository: _auctionDetailRepository);

  static AuctionDetailRepository getAuctionDetailRepository() =>
      _auctionDetailRepository;

  static AuctionListBloc getAuctionListBloc() =>
      AuctionListBloc(repository: _auctionRepository);

  static CreateAuctionBloc getCreateAuctionBloc() =>
      CreateAuctionBloc(createAuctionUseCase: _createAuctionUseCase);

  static AuctionBloc getAuctionBloc() =>
      AuctionBloc(repository: _auctionRepository);

  static PaymentBloc getPaymentBloc() => PaymentBloc(_paymentRepository);

  static CategoryBloc getCategoryBloc() =>
      CategoryBloc(getCategoriesUseCase: _getCategoriesUseCase);

  static AuthBloc getAuthBloc() => AuthBloc(
    loginUseCase: _loginUseCase,
    registerUseCase: _registerUseCase,
    updateProfileUseCase: _updateProfileUseCase,
    changePasswordUseCase: _changePasswordUseCase,
    logoutUseCase: _logoutUseCase,
    userRepository: _userRepository,
  );

  static ChatBloc getChatBloc() => _chatBloc;

  static GeminiService getGeminiService() => _geminiService;

  static LocationService getLocationService() => _locationService;

  static NotificationBloc getNotificationBloc() => NotificationBloc(
    repository: _notificationRepository,
    socketService: _socketService,
  );

  static UserRepository getUserRepository() => _userRepository;
}
