import 'package:go_router/go_router.dart';

import '../views/screens/app_base.dart';
import '../views/screens/authentication/reset_password_screen.dart';
import '../views/screens/authentication/reset_password_success_screen.dart';
import '../views/screens/authentication/signin_screen.dart';
import '../views/screens/authentication/signup_screen.dart';
import '../views/screens/authentication/social_signin_screen.dart';
import '../views/screens/onboarding/onboarding_screen.dart';
import '../views/screens/splash_screen.dart';
import '../views/widgets/error_page.dart';

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
      path: '/home',
      builder: (context, state) => const AppBase(),
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
