import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.redAccent,
    ),
  );
}

Future<void> showSuccessFlash(BuildContext context, String message,
    {FlashPosition? position,
    Color? backgroundColor,
    TextStyle? textStyle}) async {
  await showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash<dynamic>(
        controller: controller,
        behavior: FlashBehavior.floating,
        position: position ?? FlashPosition.top,
        boxShadows: kElevationToShadow[4],
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.white,
        borderWidth: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: backgroundColor ?? Colors.green,
        horizontalDismissDirection: HorizontalDismissDirection.horizontal,
        child: FlashBar(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          content: Text(
            message,
            style: textStyle ??
                const TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
          ),
        ),
      );
    },
  );
}

void showConfirmationFlash(BuildContext context, String message,
    {FlashPosition? position, Color? backgroundColor, TextStyle? textStyle}) {
  showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash<dynamic>(
        controller: controller,
        behavior: FlashBehavior.floating,
        position: position ?? FlashPosition.top,
        boxShadows: kElevationToShadow[4],
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.white,
        borderWidth: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: backgroundColor ?? Colors.amber,
        horizontalDismissDirection: HorizontalDismissDirection.horizontal,
        child: FlashBar(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          content: Text(
            message,
            style: textStyle ??
                const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  color: Colors.black,
                ),
          ),
        ),
      );
    },
  );
}

Future<void> showFailureFlash(BuildContext context, String message,
    {FlashPosition? position,
    Color? backgroundColor,
    TextStyle? textStyle}) async {
  await showFlash(
    context: context,
    duration: const Duration(seconds: 4),
    builder: (context, controller) {
      return Flash<dynamic>(
        controller: controller,
        behavior: FlashBehavior.floating,
        position: position ?? FlashPosition.bottom,
        boxShadows: kElevationToShadow[4],
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.black,
        borderWidth: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        horizontalDismissDirection: HorizontalDismissDirection.horizontal,
        backgroundColor: backgroundColor ?? Colors.redAccent,
        child: FlashBar(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          content: Text(
            message,
            style: textStyle ??
                const TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
          ),
        ),
      );
    },
  );
}
