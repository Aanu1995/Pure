import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bloc.dart';
import '../blocs/search/search_username.dart';
import '../model/pure_user_model.dart';
import '../model/route/message_route.dart';
import '../services/search_service.dart';
import '../services/user_service.dart';
import '../views/screens/app_base.dart';
import '../views/screens/authentication/reset_password_screen.dart';
import '../views/screens/authentication/reset_password_success_screen.dart';
import '../views/screens/authentication/signin_screen.dart';
import '../views/screens/authentication/signup_screen.dart';
import '../views/screens/authentication/social_signin_screen.dart';
import '../views/screens/chats/messages/messages_screen.dart';
import '../views/screens/onboarding/onboarding_screen.dart';
import '../views/screens/settings/account_screen.dart';
import '../views/screens/settings/profile/edit_profile_screen.dart';
import '../views/screens/settings/update_username_screen.dart';
import '../views/screens/splash_screen.dart';
import '../views/widgets/error_page.dart';

class AppRoute {
  static String login = "/login";

  static String home = "/home";

  // Chat
  static String message = "/home/2/message";

  // Settings
  static String editProfile = "/home/4/edit-profile";
  static String changeUsername = "/home/4/change-username";
  static String account = "/home/4/account";
}

final router = GoRouter(
  // turn off the # in the URLs on the web
  urlPathStrategy: UrlPathStrategy.path,
  routes: [
    GoRoute(
      name: "/",
      path: "/",
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: "board",
      path: '/board',
      builder: (context, state) => const OnBoardingScreen(),
    ),
    GoRoute(
      name: "home",
      path: '/home/:fid',
      builder: (context, state) {
        final tabIndex = int.parse(state.params['fid']!);
        return AppBase(initialIndex: tabIndex);
      },
      routes: [
        // Chat
        GoRoute(
          name: "message",
          path: 'message',
          builder: (context, state) {
            final msgRoute = state.extra as MessageRoute;
            return BlocProvider.value(
              value: msgRoute.state!,
              child: MessagesScreen(msgRoute: msgRoute),
            );
          },
        ),

        // Settings
        GoRoute(
          name: "account",
          path: 'account',
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          name: "edit-profile",
          path: 'edit-profile',
          builder: (context, state) {
            final user = state.extra as PureUser;
            return BlocProvider(
              create: (_) => UserProfileCubit(UserServiceImpl()),
              child: EditProfileScreen(user: user),
            );
          },
        ),
        GoRoute(
          name: "change-username",
          path: 'change-username',
          builder: (context, state) {
            final user = state.extra as PureUser;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => SearchBloc(SearchServiceImpl()),
                ),
                BlocProvider(
                  create: (_) => UserProfileCubit(UserServiceImpl()),
                )
              ],
              child: UpdateUsernameScreen(user: user),
            );
          },
        ),
      ],
    ),
    GoRoute(
      name: "social",
      path: '/social',
      builder: (context, state) => const SocialSignInScreen(),
    ),
    GoRoute(
      name: "signin",
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      name: "signup",
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      name: "resetpassword",
      path: '/resetpassword',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      name: "resetpasswordsuccess",
      path: '/resetpasswordsuccess',
      builder: (context, state) => const ResetPasswordSuccessScreen(),
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
);
