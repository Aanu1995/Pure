import 'package:flutter/material.dart';

void push(
    {required BuildContext context,
    bool rootNavigator = false,
    required Widget page}) {
  Navigator.of(context, rootNavigator: rootNavigator).push<void>(
    MaterialPageRoute(builder: (context) => page),
  );
}

void pushNamed(
    {required BuildContext context,
    bool rootNavigator = false,
    required String page}) {
  Navigator.of(context, rootNavigator: rootNavigator).pushNamed(page);
}

void pushReplacementNamed(
    {required BuildContext context,
    bool rootNavigator = false,
    required String page}) {
  Navigator.of(context, rootNavigator: rootNavigator)
      .pushReplacementNamed(page);
}

void pushReplacement({required BuildContext context, required Widget page}) {
  Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(builder: (context) => page));
}

void pushAndRemoveUntil(
    {required BuildContext context,
    bool rootNavigator = false,
    required Widget page}) {
  Navigator.of(context, rootNavigator: rootNavigator).pushAndRemoveUntil<void>(
    MaterialPageRoute(builder: (context) => page),
    (Route<dynamic> route) => false,
  );
}

void pushNamedAndRemoveUntil(
    {required BuildContext context,
    required String page,
    bool rootNavigator = false}) {
  Navigator.of(context, rootNavigator: rootNavigator)
      .pushNamedAndRemoveUntil(page, (route) => false);
}

void pop({required BuildContext context, bool rootNavigator = false}) {
  Navigator.of(context, rootNavigator: rootNavigator).pop();
}
