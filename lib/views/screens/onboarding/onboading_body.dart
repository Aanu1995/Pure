import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/palette.dart';

class OnBoardingBody extends StatelessWidget {
  const OnBoardingBody({
    Key? key,
    required this.image,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  final String image;
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image),
        SizedBox(height: 1.sh * 0.07),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontFamily: Palette.migraFontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 1.sw * 0.8,
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.3,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
