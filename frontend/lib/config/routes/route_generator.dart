import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart';
import 'package:frontend/presentation/pages/my_activity/my_activity_page.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/auction/auction_event.dart';
import '../../presentation/bloc/category/category_event.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/layouts/main_layout.dart';
import '../../presentation/pages/auction/auction_list_page.dart';
import '../../presentation/pages/auction/create_auction_page.dart';
import '../../presentation/pages/auction/auction_detail_page.dart';
import '../../presentation/pages/wallet/wallet_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/public_profile_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/notification/notification_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // Auth routes (outside ShellRoute - don't need Bloc)
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),

    // ShellRoute: Provides Bloc to all nested routes
    ShellRoute(
      builder: (context, state, child) {
        // Bloc providers at router level - created once, shared by all routes
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  InjectionContainer.getAuctionBloc()..add(GetAuctions()),
            ),
            BlocProvider(
              create: (context) =>
                  InjectionContainer.getCategoryBloc()..add(GetCategories()),
            ),
            BlocProvider(
              create: (context) => InjectionContainer.getNotificationBloc(),
            ),
          ],
          child: child, // child = currently active nested route
        );
      },
      routes: [
        // Main app routes (all have access to AuctionBloc & CategoryBloc)
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: AppRoutes.auctionList,
          builder: (context, state) => const AuctionListPage(),
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
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: '${AppRoutes.publicProfile}/:userId',
          builder: (context, state) => PublicProfilePage(
            userId: state.pathParameters['userId']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationPage(),
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
    ),
  ],
);
