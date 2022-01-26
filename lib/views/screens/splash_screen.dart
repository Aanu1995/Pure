import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/bloc.dart';
import '../../model/pure_user_model.dart';
import '../../utils/image_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await context.read<OnBoardingCubit>().isUserBoarded();
    final onboardingState = context.read<OnBoardingCubit>().state;
    if (onboardingState is NotBoarded) {
      context.goNamed("board");
    } else {
      await context.read<AuthCubit>().authenticateUser();
      final authState = context.read<AuthCubit>().state;
      if (authState is UnAuthenticated) {
        context.goNamed("social");
      } else if (authState is Authenticated) {
        CurrentUser.setUserId = authState.user.id;
        context.go("/home/0");
      }
    }
    initializeLoadingAttributes(context);
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
    return Scaffold(
      body: Center(
        child: Image.asset(
          ImageUtils.logo,
          fit: BoxFit.contain,
          height: 45.h,
          width: 150.w,
        ),
      ),
    );
  }
}
