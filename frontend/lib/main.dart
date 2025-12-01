import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';

class ApiConfig {
  static late final String baseUrl;

  static void init() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:3000';
    } else {
      // Android emulator -> 10.0.2.2 ; iOS simulator -> localhost
      baseUrl = 'http://10.0.2.2:3000';
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.init();

  await InjectionContainer.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              InjectionContainer.getAuthBloc()
                ..add(const AuthCheckStatusEvent()),
        ),
<<<<<<< Updated upstream
=======
        BlocProvider<MyActivityBloc>(
          create: (context) => InjectionContainer.getMyActivityBloc(),
        ),
        BlocProvider<AuctionDetailBloc>(
          create: (context) => InjectionContainer.getAuctionDetailBloc(),
        ),
        BlocProvider<AuctionListBloc>(
          create: (context) => InjectionContainer.getAuctionListBloc(),
        ),
        BlocProvider<PaymentBloc>(
          create: (context) => InjectionContainer.getPaymentBloc(),
        ),
>>>>>>> Stashed changes
      ],
      child: MaterialApp.router(
        title: 'BidChain',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
