import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'screens/widgets/custom_multi_bloc_provider.dart';
import 'utils/app_theme.dart';
import 'utils/flavors.dart';
import 'utils/routing.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomMultiBlocProvider(
      child: ScreenUtilInit(
        // the resolution for the design in Figma
        designSize: const Size(375, 812),
        builder: () {
          return GestureDetector(
            onTap: () => removeKeyboardFocus(context),
            child: MaterialApp.router(
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              title: F.title,
              theme: Palette.lightTheme.copyWith(
                primaryColorBrightness: Brightness.light,
                appBarTheme: Palette.lightTheme.appBarTheme.copyWith(
                  titleTextStyle: Palette.appBarStyle(),
                ),
              ),
              darkTheme: Palette.darkTheme.copyWith(
                primaryColorBrightness: Brightness.dark,
                appBarTheme: Palette.darkTheme.appBarTheme.copyWith(
                  titleTextStyle: Palette.appBarStyle(isLightMode: false),
                ),
              ),
              debugShowCheckedModeBanner: false,
              builder: EasyLoading.init(),
            ),
          );
        },
      ),
    );
  }

  // This method hides keyboard when it is tapped outside the focus area
  // This is implemented to get expected behaviour in IOS

  void removeKeyboardFocus(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
