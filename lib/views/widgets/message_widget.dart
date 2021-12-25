import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure/utils/palette.dart';

class MessageDisplay extends StatelessWidget {
  final String? title;
  final String? image;
  final String? description;
  final String? buttonTitle;
  final double? fontSize;
  final void Function()? onPressed;
  const MessageDisplay({
    Key? key,
    this.title,
    this.image,
    this.description,
    this.buttonTitle,
    this.onPressed,
    this.fontSize,
  }) : super(key: key);

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
          if (image != null)
            Image.asset(
              image!,
              width: 1.sw * 0.6,
              height: 1.sw * 0.6,
            ),
          const SizedBox(height: 16.0),
          Text(
            title ?? "No results found",
            textAlign: TextAlign.center,
            style: _style.copyWith(
              fontSize: fontSize ?? 24.0,
              fontFamily: Palette.migraFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 1.0.sw * 0.7,
            child: Text(
              description ?? "Try shortening or rephrasing your search",
              textAlign: TextAlign.center,
              style: _style.copyWith(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          if (onPressed != null)
            OutlinedButton(
              style: OutlinedButton.styleFrom(shape: StadiumBorder()),
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(
                buttonTitle ?? "Edit search",
                style: _style.copyWith(
                  fontSize: 17,
                  color: Palette.tintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
