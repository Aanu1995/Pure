import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator(
      {Key? key, this.defaultColor = false, this.size})
      : super(key: key);

  final bool defaultColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final _size = size ?? (Platform.isIOS ? 50.0 : 35.0);
    return SizedBox(
      width: _size,
      height: _size,
      child: Platform.isIOS
          ? const CupertinoActivityIndicator()
          : CircularProgressIndicator(
              strokeWidth: _size >= 30 ? 4.0 : 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
    );
  }
}

class RefreshLoadingWidget extends StatelessWidget {
  final bool isTransparent;
  const RefreshLoadingWidget({Key? key, this.isTransparent = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isTransparent ? Colors.transparent : Colors.grey[200]!,
      child: Column(
        children: [
          if (!isTransparent) Divider(height: 0.0),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator()
                      : CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16.0),
                Text(
                  "Loading",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (!isTransparent) Divider(height: 0.0),
        ],
      ),
    );
  }
}
