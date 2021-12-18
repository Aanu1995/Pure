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
    BlocProvider.of<OnBoardingCubit>(context).isUserBoarded();
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

    return MultiBlocListener(
      listeners: [
        BlocListener<OnBoardingCubit, OnBoardingState>(
          listener: (context, state) {
            if (state is NotBoarded) {
              context.goNamed("board");
            } else {
              BlocProvider.of<AuthCubit>(context).authenticateUser();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState is UnAuthenticated) {
              context.goNamed("social");
            } else if (authState is Authenticated) {
              BlocProvider.of<BottomBarBloc>(context).add(0);
              CurrentUser.setUserId = authState.user.id;
              context.goNamed("home");
            }
          },
        ),
      ],
      child: Scaffold(
        body: Image.asset(
          ImageUtils.splash,
          fit: BoxFit.contain,
          height: 1.sh,
          width: 1.sw,
        ),
      ),
    );
  }
}
