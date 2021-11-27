import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class Palette {
  // Fonts

  static const String migraFontFamily = "Migra";
  static const String sanFontFamily = "PublicSans";

  // primaryColor
  static const Color tintColor = const Color(0xFFE1A043);
  static const Color greenColor = const Color(0xFF36CC45);

  /// color for text theme
  static const Color whiteColor = Color(0xFFEBFAFF);
  static const Color surfaceColor = Color(0xFFF7F7F7);
  static const Color titleColor = Color(0xFF07455B);

  static final lightTheme = FlexThemeData.light(
    fontFamily: "PublicSans",
    scaffoldBackground: const Color(0xFFFFFFFF),
    appBarBackground: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    dialogBackground: const Color(0xFFF0F0F0),
    colors: FlexSchemeColor.from(
      primary: Palette.tintColor,
      primaryVariant: const Color(0xFF000000),
      secondary: const Color(0xFFF2F3F5),
      secondaryVariant: const Color(0xFF71747A),
    ),
  );

  static final darkTheme = FlexThemeData.dark(
    fontFamily: "PublicSans",
    scaffoldBackground: const Color(0xFF0A0A0A),
    appBarBackground: const Color(0xFF0A0A0A),
    surface: const Color(0xFF0A0A0A),
    dialogBackground: const Color(0xFF242424),
    colors: FlexSchemeColor.from(
      primary: Palette.tintColor,
      primaryVariant: const Color(0xFFFFFFFF),
      secondary: const Color(0xFF1A1A1A),
      secondaryVariant: const Color(0xFF80807E),
    ),
  );

  static TextStyle appBarStyle({bool isLightMode = true}) {
    return TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      fontFamily: "Migra",
      color: isLightMode ? Colors.black : Colors.white,
    );
  }
}
