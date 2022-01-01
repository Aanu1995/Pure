import 'package:flutter/material.dart';

class CustomKeepAlive extends StatefulWidget {
  final Widget child;

  const CustomKeepAlive({
    required Key key,
    required this.child,
  }) : super(key: key);

  @override
  State<CustomKeepAlive> createState() => _CustomKeepAliveState();
}

class _CustomKeepAliveState extends State<CustomKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
