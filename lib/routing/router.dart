// Routes manager
import 'dart:collection';

import 'package:diakron_participant/data/repositories/auth/auth_repository.dart';
import 'package:diakron_participant/data/repositories/map/map_repository.dart';
import 'package:diakron_participant/data/repositories/map/map_repository_impl.dart';
import 'package:diakron_participant/data/repositories/user/participant_repository.dart';
import 'package:diakron_participant/routing/routes.dart';
import 'package:diakron_participant/ui/auth/forgot_password/view_models/forgot_password_viewmodel.dart';
import 'package:diakron_participant/ui/auth/forgot_password/widgets/forgot_password_screen.dart';
import 'package:diakron_participant/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:diakron_participant/ui/auth/login/widgets/login_screen.dart';
import 'package:diakron_participant/ui/auth/reset_password/view_models/reset_password_viewmodel.dart';
import 'package:diakron_participant/ui/auth/reset_password/widgets/reset_password_screen.dart';
import 'package:diakron_participant/ui/auth/sigunp/view_models/signup_viewmodel.dart';
import 'package:diakron_participant/ui/auth/sigunp/widgets/signup_screen.dart';
import 'package:diakron_participant/ui/home/coupon_details/view_models/coupon_detail_viewmodel.dart';
import 'package:diakron_participant/ui/home/coupon_details/widgets/coupon_detail_screen.dart';
import 'package:diakron_participant/ui/map/view_models/map_viewmodel.dart';
import 'package:diakron_participant/ui/map/widgets/map_screen.dart';
import 'package:diakron_participant/ui/profile/view_models/profile_viewmodel.dart';
import 'package:diakron_participant/ui/profile/widgets/profle_screen.dart';
import 'package:diakron_participant/ui/progress/view_models/favorites_viewmodel.dart';
import 'package:diakron_participant/ui/progress/widgets/favorites_screen.dart';
import 'package:diakron_participant/ui/home/view_models/home_viewmodel.dart';
import 'package:diakron_participant/ui/home/widgets/home_screen.dart';
import 'package:diakron_participant/ui/main/widgets/main_screen.dart';
import 'package:diakron_participant/ui/qr_coupon/widgets/qr_coupon_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true, // TESTING
  refreshListenable: authRepository,
  redirect: _redirect,

  routes: [
    GoRoute(
      path:
          '${Routes.qrCoupon}/:userId/:couponId', // Definimos los parámetros en el path
      name: Routes.qrCoupon,
      builder: (context, state) {
        // Extraemos los parámetros y los convertimos a int
        final userId = state.pathParameters['userId']!;
        final couponId = int.parse(state.pathParameters['couponId']!);

        return QRCouponScreen(userId: userId, couponId: couponId);
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: HomeScreen(
              viewModel: HomeViewModel(
                participantRepository: context.read<ParticipantRepository>(),
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Use a simple fade so the pre-charged home page appears smoothly
              return FadeTransition(opacity: animation, child: child);
            },
          ),
          routes: [
            GoRoute(
              path: ':id', // This matches the ${center.id} in your push
              builder: (context, state) {
                final String idString = state.pathParameters['id']!;
                // Extract the ID from the URL path
                final viewModel = CouponDetailViewmodel(
                  participantRepository: context.read<ParticipantRepository>(),
                  couponId: int.parse(idString),
                );
                return CouponDetailScreen(viewModel: viewModel);
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.favorites,
          builder: (context, state) {
            final viewModel = FavoritesViewmodel(
              participantRepository: context.read<ParticipantRepository>(),
            );
            return FavoritesScreen(viewModel: viewModel);
          },
        ),

        GoRoute(
          path: Routes.scanner,
          builder: (context, state) {
            return const Scaffold(body: Center(child: Text("Scanner")));
          },
        ),

        GoRoute(
          path: Routes.map,
          builder: (context, state) {
            final viewModel = MapViewModel(repository: MapRepositoryImpl());
            return MapScreen(viewModel: viewModel);
          },
          // routes: [
          //   GoRoute(
          //     path: Routes
          //         .createRelative, // This matches the ${center.id} in your push
          //     builder: (context, state) {
          //       final viewModel = CreateCouponViewmodel(

          //         userRepository: context.read<UserRepository>(),
          //       );
          //       return CreateCouponScreen(viewModel: viewModel);
          //     },
          //   ),

          //   GoRoute(
          //     path: ':id', // This matches the ${center.id} in your push
          //     builder: (context, state) {
          //       final String idString = state.pathParameters['id']!;
          //       // Extract the ID from the URL path
          //       final viewModel = RUDCouponViewmodel(
          //         userRepository: context.read<UserRepository>(),
          //         couponId: int.parse(idString),
          //       );
          //       return RUDCouponScreen(viewModel: viewModel);
          //     },
          //   ),
          // ],
        ),

        GoRoute(
          path: Routes.profile,
          builder: (context, state) {
            return ProfileScreen(
              viewModel: ProfileViewmodel(
                participantRepository: context.read<ParticipantRepository>(),
              ),
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final viewModel = LoginViewModel(
          authRepository: context.read<AuthRepository>(),
        );
        return LoginScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.forgotpassword,
      builder: (context, state) {
        final viewModel = ForgotPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ForgotPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.resetpassword,
      builder: (context, state) {
        final viewModel = ResetPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ResetPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) {
        final viewModel = SignupViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return SignupScreen(viewModel: viewModel);
      },
    ),
  ],
);
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final authRepo = context.read<AuthRepository>();

  final bool loggedIn = authRepo.isAuthenticated;
  // Auth Check
  final bool isAtAuthPage = [
    Routes.login,
    Routes.signup,
    Routes.forgotpassword,
    Routes.resetpassword,
  ].contains(state.matchedLocation);

  // // Locations
  final bool isAtLogin = state.matchedLocation == Routes.login;

  // Password Recovery
  if (authRepo.isRecoveringPassword) {
    return Routes.resetpassword;
  }

  // If not logged in and not in auth page go to Login
  if (!loggedIn) {
    return isAtAuthPage ? null : Routes.login;
  }

  if (authRepo.isVerifyingAuth) {
    return null;
  }

  // Logged in in login go Home
  if (loggedIn && isAtLogin) {
    return Routes.home;
  }

  return null;
}
