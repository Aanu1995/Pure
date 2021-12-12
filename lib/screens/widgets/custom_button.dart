import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure/utils/app_theme.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.title,
    this.width,
    this.height,
    this.shape,
    this.backgroundColor,
    this.side,
    this.style,
  }) : super(key: key);
  final String title;
  final double? width;
  final double? height;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final Color? backgroundColor;
  final TextStyle? style;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 1.sw * 0.34,
      height: height ?? 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: side,
          shape: shape,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: style ??
              TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.title,
    this.width,
    this.height,
    this.shape,
    this.backgroundColor,
    this.side,
    this.style,
  }) : super(key: key);
  final String title;
  final double? width;
  final double? height;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final Color? backgroundColor;
  final TextStyle? style;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 1.sw * 0.34,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: backgroundColor ?? Palette.tintColor,
          side: side,
          shape: shape,
        ),
        child: Text(
          title,
          style: style ??
              TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
        ),
      ),
    );
  }
}
