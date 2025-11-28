import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart';
import 'package:frontend/presentation/pages/my_activity/my_activity_page.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/layouts/main_layout.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/auction/auction_list_page.dart';
import '../../presentation/pages/auction/auction_detail_page.dart';
import '../../presentation/pages/auction/create_auction_page.dart';
import '../../presentation/pages/wallet/wallet_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/component_showcase_page.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.login, // Start with login page
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: AppRoutes.auctionList,
      builder: (context, state) => BlocProvider(
        create: (context) => InjectionContainer.getAuctionListBloc(),
        child: const AuctionListPage(),
      ),
    ),

    GoRoute(
      path: AppRoutes.createAuction,
      builder: (context, state) => const CreateAuctionPage(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => const WalletPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.componentShowcase,
      builder: (context, state) => const ComponentShowcasePage(),
    ),
    GoRoute(
      path: AppRoutes.myActivity,
      builder: (context, state) => BlocProvider(
        create: (context) => InjectionContainer.getMyActivityBloc(),
        child: const MyActivityPage(),
      ),
    ),
    GoRoute(
      path: '${AppRoutes.auctionDetail}/:id',
      builder: (context, state) => BlocProvider(
        create: (context) => InjectionContainer.getAuctionDetailBloc(),
        child: AuctionDetailPage(auctionId: state.pathParameters['id']!),
      ),
    ),
  ],
);
