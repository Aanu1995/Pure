import 'package:flutter/material.dart';

import '../../../../utils/palette.dart';

class IntroSection extends StatelessWidget {
  final String? title;
  final double? fontSize;
  const IntroSection({Key? key, this.title, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title ?? "Pure",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize ?? 64,
          fontFamily: Palette.migraFontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
