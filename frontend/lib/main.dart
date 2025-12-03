import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/presentation/bloc/auction_detail/auction_detail_bloc.dart';
import 'package:frontend/presentation/bloc/auction_list/auction_list_bloc.dart';
import 'package:frontend/presentation/bloc/my_activity/my_activity_bloc.dart';
import 'package:frontend/presentation/bloc/chat/chat_bloc.dart';
import 'config/routes/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/payment/payment_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'core/services/notification_popup_service.dart';

class ApiConfig {
  static late final String baseUrl;

  static void init() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:3000';
    } else {
      baseUrl = 'http://10.0.2.2:3000';
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
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
        BlocProvider<ChatBloc>(
          create: (context) => InjectionContainer.getChatBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) =>
              InjectionContainer.getNotificationBloc()
                ..add(FetchNotificationsEvent()),
        ),
      ],

      // 🔥 SỬA THEO YÊU CẦU
      child: OverlaySupport.global(
        child: MaterialApp.router(
          title: 'BidChain',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.lightTheme,
        ),
      ),
    );
  }
}
