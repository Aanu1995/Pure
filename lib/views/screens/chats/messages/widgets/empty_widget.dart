import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/image_utils.dart';
import '../../../../widgets/message_widget.dart';

class EmptyMessage extends StatelessWidget {
  final String firstName;
  final ValueChanged<String> onPressed;
  const EmptyMessage(
      {Key? key, required this.firstName, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 1.sh * 0.1),
          MessageDisplay(
            image: Theme.of(context).brightness == Brightness.light
                ? ImageUtils.emptyMessageLight
                : ImageUtils.emptyMessageDark,
            title: "No messages here yet...",
            description: "Start a conversation with $firstName",
            buttonTitle: "",
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).dialogBackgroundColor,
                ),
                onPressed: () => onPressed.call("👋"),
                child: Text(
                  "👋",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).dialogBackgroundColor,
                ),
                onPressed: () => onPressed.call("Hello, $firstName!"),
                child: Text(
                  "Hello, $firstName!",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                ),
              )
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).dialogBackgroundColor,
            ),
            onPressed: () => onPressed.call("Hey, nice to meet you!"),
            child: Text(
              "Hey, nice to meet you!",
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
            ),
          )
        ],
      ),
    );
  }
}
