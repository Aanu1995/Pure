import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/chat/attachment_model.dart';
import '../../../../../model/chat/message_model.dart';
import 'docfile_preview_widget.dart';
import 'file_widget.dart';
import 'message_widgets.dart';
import 'pure_link_preview.dart';

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
              child: _MessageBody(message: message),
            ),
            // shows failed to deliver message
            if (message.receipt == Receipt.Failed)
              FailedToDeliverMessageWidget(chatId: chatId)
          ],
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  final MessageModel message;
  const _MessageBody({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if text is empty, that means there is an attachment
    if (message.text.isEmpty && message.attachments!.first is ImageAttachment) {
      // show image attachments with time shown on top of it
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          ImageView(attachments: message.attachments!),
          TrailingText(
            key: ValueKey("${message.messageId}${message.receipt}"),
            time: message.time,
            receipt: message.receipt,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          )
        ],
      );
    } else {
      bool hasAttachments = message.attachments != null;
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (hasAttachments)
            // show attachments
            if (message.attachments!.first is DocumentAttachment)
              DocFilePreviewWidget(
                key: ValueKey(message.attachments?.length),
                message: message,
                isReceipient: false,
                color: Theme.of(context).colorScheme.secondary,
                trailingColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.6),
                attachment: message.attachments!.first as DocumentAttachment,
              )
            else if (message.attachments!.first is VoiceAttachment)
              Offstage()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageView(
                    key: ValueKey(message.attachments?.length),
                    attachments: message.attachments!,
                  ),
                  TextWidget(
                    key: ValueKey("${message.messageId}${message.text}"),
                    text: message.text,
                  ),
                ],
              )
          else
            // show text only
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PureLinkPreview(
                  color: Theme.of(context).colorScheme.secondary,
                  linkPreviedData: message.linkPreviewData,
                ),
                TextWidget(
                  key: ValueKey("${message.messageId}${message.text}"),
                  text: message.text,
                ),
              ],
            ),
          // Date Widget
          if (message.attachments?.first is! DocumentAttachment)
            TrailingText(
              key: ValueKey("${message.messageId}${message.receipt}"),
              time: message.time,
              receipt: message.receipt,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            )
        ],
      );
    }
  }
}
