import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bloc.dart';
import '../model/pure_user_model.dart';
import '../screens/views/app_base.dart';
import '../screens/views/authentication/reset_password_screen.dart';
import '../screens/views/authentication/reset_password_success_screen.dart';
import '../screens/views/authentication/signin_screen.dart';
import '../screens/views/authentication/signup_screen.dart';
import '../screens/views/authentication/social_signin_screen.dart';
import '../screens/views/onboarding/onboarding_screen.dart';
import '../screens/views/splash_screen.dart';
import '../screens/widgets/error_page.dart';

final router = GoRouter(
  // turn off the # in the URLs on the web
  urlPathStrategy: UrlPathStrategy.path,

  routes: [
    GoRoute(
      name: "/",
      path: "/",
      builder: (context, state) {
        initializeLoadingAttributes(context);
        final onboardingState =
            BlocProvider.of<OnBoardingCubit>(context, listen: true).state;
        if (onboardingState is NotBoarded)
          return OnBoardingScreen();
        else if (onboardingState is OnBoarded) {
          final authState =
              BlocProvider.of<AuthCubit>(context, listen: true).state;
          if (authState is UnAuthenticated) {
            return const SocialSignInScreen();
          } else if (authState is Authenticated) {
            CurrentUser.setUserId = authState.user.id;
            BlocProvider.of<BottomBarBloc>(context).add(0);
            return const AppBase();
          }
        }
        return const SplashScreen();
      },
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

void initializeLoadingAttributes(BuildContext context) {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..userInteractions = false
    ..backgroundColor = Theme.of(context).primaryColor;
}
