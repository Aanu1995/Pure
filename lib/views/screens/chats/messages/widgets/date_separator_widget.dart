import 'package:flutter/material.dart';

import '../../../../../utils/app_utils.dart';

class GroupDateSeparator extends StatelessWidget {
  final DateTime date;
  const GroupDateSeparator({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            groupDate(date),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class NewMessageSeparator extends StatelessWidget {
  const NewMessageSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryVariant.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "New Messages",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
