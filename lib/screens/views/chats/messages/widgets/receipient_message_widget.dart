import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/chat/message_model.dart';
import 'message_screen_widget.dart';
import 'message_widgets.dart';

class ReceipientMessage extends StatelessWidget {
  final MessageModel message;
  final bool hideNip;
  const ReceipientMessage(
      {Key? key, required this.message, required this.hideNip})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.72),
        child: Bubble(
          elevation: 0.0,
          margin: BubbleEdges.only(left: hideNip ? 8.0 : 0.0),
          padding: const BubbleEdges.all(3.0),
          stick: true,
          nip: hideNip ? null : BubbleNip.leftTop,
          color: Theme.of(context).colorScheme.secondary,
          child: message.text.isEmpty
              ? Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    FileWidget(attachments: message.attachments!),
                    TrailingText(
                      key: ValueKey("${message.messageId}${message.receipt}"),
                      width: 64.0,
                      time: message.time,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryVariant
                          .withOpacity(0.8),
                    )
                  ],
                )
              : Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments != null &&
                            message.attachments!.isNotEmpty)
                          FileWidget(attachments: message.attachments!),
                        TextWidget(
                          key: ValueKey("${message.messageId}${message.text}"),
                          text: message.text,
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                      ],
                    ),
                    TrailingText(
                      key: ValueKey("${message.messageId}${message.receipt}"),
                      width: 64.0,
                      time: message.time,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryVariant
                          .withOpacity(0.6),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
