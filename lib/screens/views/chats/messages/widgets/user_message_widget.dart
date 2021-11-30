import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/chat/message_model.dart';
import 'message_screen_widget.dart';
import 'message_widgets.dart';

class UserMessage extends StatelessWidget {
  final String chatId;
  final MessageModel message;
  final bool hideNip;
  const UserMessage({
    Key? key,
    required this.message,
    required this.chatId,
    required this.hideNip,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Bubble(
              elevation: 0.0,
              margin: BubbleEdges.only(right: hideNip ? 8.0 : 0.0),
              padding: const BubbleEdges.all(3.0),
              stick: true,
              nip: hideNip ? null : BubbleNip.rightTop,
              color: Theme.of(context).primaryColor,
              child: message.text.isEmpty
                  ? Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        FileWidget(attachments: message.attachments!),
                        TrailingText(
                          key: ValueKey(
                              "${message.messageId}${message.receipt}"),
                          time: message.time,
                          receipt: message.receipt,
                          color: Theme.of(context)
                              .colorScheme
                              .surface
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
                              key: ValueKey(
                                  "${message.messageId}${message.text}"),
                              text: message.text,
                            ),
                          ],
                        ),
                        TrailingText(
                          key: ValueKey(
                              "${message.messageId}${message.receipt}"),
                          time: message.time,
                          receipt: message.receipt,
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.6),
                        )
                      ],
                    ),
            ),
            // shows failed to deliver message
            if (message.receipt == Receipt.Failed)
              FailedToDeliverMessageWidget(
                chatId: chatId,
                hasAttachments: message.attachments!.isNotEmpty,
              )
          ],
        ),
      ),
    );
  }
}
