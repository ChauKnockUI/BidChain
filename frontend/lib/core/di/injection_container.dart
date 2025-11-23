import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../network/dio_client.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late DioClient _dioClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late AuthRepository _authRepository;
  static late LoginUseCase _loginUseCase;
  static late RegisterUseCase _registerUseCase;

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
  }

  // Getters
  static AuthBloc getAuthBloc() => AuthBloc(
    loginUseCase: _loginUseCase,
    registerUseCase: _registerUseCase,
  );

  static AuthRepository getAuthRepository() => _authRepository;
  static LoginUseCase getLoginUseCase() => _loginUseCase;
  static RegisterUseCase getRegisterUseCase() => _registerUseCase;
}
