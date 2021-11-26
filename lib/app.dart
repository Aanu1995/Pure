import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'blocs/bloc.dart';
import 'model/pure_user_model.dart';
import 'screens/views/app_base.dart';
import 'screens/views/authentication/social_signin_screen.dart';
import 'screens/views/onboarding/onboarding_screen.dart';
import 'screens/views/splash_screen.dart';
import 'screens/widgets/custom_multi_bloc_provider.dart';
import 'utils/app_theme.dart';
import 'utils/flavors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // the resolution for the design in Figma
      designSize: const Size(360, 640),
      builder: () {
        return CustomMultiBlocProvider(
          child: GestureDetector(
            onTap: () => removeKeyboardFocus(context),
            child: MaterialApp(
              title: F.title,
              theme: Palette.lightTheme.copyWith(
                appBarTheme: Palette.lightTheme.appBarTheme.copyWith(
                  titleTextStyle: Palette.appBarStyle(),
                ),
              ),
              darkTheme: Palette.darkTheme.copyWith(
                appBarTheme: Palette.darkTheme.appBarTheme.copyWith(
                  titleTextStyle: Palette.appBarStyle(isLightMode: false),
                ),
              ),
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              home: const RootWidget(),
              builder: EasyLoading.init(),
            ),
          ),
        );
      },
    );
  }

  // This method hides keyboard when it is tapped outside the focus area
  // This is implemented to get expected behaviour in IOS

  void removeKeyboardFocus(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class RootWidget extends StatefulWidget {
  const RootWidget({Key? key}) : super(key: key);

  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  @override
  void initState() {
    super.initState();
    setDefaultSelectedTab();
  }

  void setDefaultSelectedTab() {
    // the default selected tab has index of 0
    if (mounted) BlocProvider.of<BottomBarBloc>(context).add(0);
  }

  void initializeLoadingAttributes(BuildContext context) {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..userInteractions = false
      ..backgroundColor = Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    initializeLoadingAttributes(context);
    return BlocBuilder<OnBoardingCubit, OnBoardingState>(
      builder: (context, state) {
        if (state is NotBoarded) {
          return const OnBoardingScreen();
        } else if (state is OnBoarded) {
          return BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous is! Authenticated,
            builder: (context, state) {
              if (state is UnAuthenticated) {
                return const SocialSignInScreen();
              } else if (state is Authenticated) {
                CurrentUser.setUserId = state.user.id;
                return AppBase();
              }
              return const SplashScreen();
            },
          );
        }
        return const SplashScreen();
      },
    );
  }
}
