import 'package:flutter/material.dart';

void push({required BuildContext context, required Widget page}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (context) => page),
  );
}

void pushNamed({required BuildContext context, required String page}) {
  Navigator.of(context).pushNamed(page);
}

void pushReplacementNamed(
    {required BuildContext context, required String page}) {
  Navigator.of(context).pushReplacementNamed(page);
}

void pushReplacement({required BuildContext context, required Widget page}) {
  Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(builder: (context) => page));
}

void pushAndRemoveUntil({required BuildContext context, required Widget page}) {
  Navigator.of(context).pushAndRemoveUntil<void>(
    MaterialPageRoute(builder: (context) => page),
    (Route<dynamic> route) => false,
  );
}

void pushNamedAndRemoveUntil(
    {required BuildContext context, required String page}) {
  Navigator.of(context).pushNamedAndRemoveUntil(page, (route) => false);
}

void pop({required BuildContext context}) {
  Navigator.of(context).pop();
}
