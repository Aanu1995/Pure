import 'package:flutter/material.dart';

import '../../../../utils/palette.dart';
import '../../../../utils/image_utils.dart';

class NoNotificationWidget extends StatelessWidget {
  const NoNotificationWidget({Key? key}) : super(key: key);

  final _style = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // images
          Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? ImageUtils.notifyLight
                : ImageUtils.notifyDark,
          ),

          const SizedBox(height: 20.0),
          Text(
            "Nothing here yet...",
            textAlign: TextAlign.center,
            style: _style.copyWith(
              fontSize: 24,
              fontFamily: Palette.migraFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            "You’ll be notifed once you get an update",
            textAlign: TextAlign.center,
            style: _style.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
          ),
        ],
      ),
    );
  }
}
