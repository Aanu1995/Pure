import 'package:flutter/material.dart';

class RefreshFailureWidget extends StatelessWidget {
  const RefreshFailureWidget({Key? key, required this.onTap}) : super(key: key);
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Oops! something went wrong',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Try again',
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ],
    );
  }
}

class LoadMoreErrorWidget extends StatelessWidget {
  final void Function()? onTap;
  final String message;
  const LoadMoreErrorWidget(
      {Key? key, required this.onTap, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: Text(
                  'Try again',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
