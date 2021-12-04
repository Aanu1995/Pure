import 'package:bubble/bubble.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/attachment_model.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import 'docfile_preview_widget.dart';
import 'file_widget.dart';
import 'message_widgets.dart';

class ReceipientMessage extends StatefulWidget {
  final MessageModel message;
  final bool hideNip;
  final bool isGroupMessage;
  const ReceipientMessage(
      {Key? key,
      required this.message,
      required this.hideNip,
      this.isGroupMessage = false})
      : super(key: key);

  @override
  State<ReceipientMessage> createState() => _ReceipientMessageState();
}

class _ReceipientMessageState extends State<ReceipientMessage> {
  PureUser? _senderUser;

  @override
  Widget build(BuildContext context) {
    if (widget.isGroupMessage) {
      getSenderName(context, widget.message.senderId);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.72),
        child: Bubble(
          elevation: 0.0,
          margin: BubbleEdges.only(left: widget.hideNip ? 8.0 : 0.0),
          padding: const BubbleEdges.all(3.0),
          stick: true,
          nip: widget.hideNip ? null : BubbleNip.leftTop,
          color: Theme.of(context).colorScheme.secondary,
          child: widget.isGroupMessage
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 2),
                      child: Text(
                        _senderUser?.fullName ?? "--",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _senderUser?.color ?? Colors.green,
                        ),
                      ),
                    ),
                    _MessageBody(message: widget.message),
                  ],
                )
              : _MessageBody(message: widget.message),
        ),
      ),
    );
  }

  void getSenderName(BuildContext context, String userId) {
    final state = BlocProvider.of<GroupCubit>(context).state;
    if (state is GroupMembers)
      _senderUser =
          state.members.firstWhereOrNull((member) => member.id == userId);
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
                color: Theme.of(context).colorScheme.primaryVariant,
                trailingColor: Theme.of(context)
                    .colorScheme
                    .primaryVariant
                    .withOpacity(0.6),
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
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                ],
              )
          else
            // show text only
            TextWidget(
              key: ValueKey("${message.messageId}${message.text}"),
              text: message.text,
              color: Theme.of(context).colorScheme.primaryVariant,
            ),
          // Date Widget
          if (message.attachments?.first is! DocumentAttachment)
            TrailingText(
              key: ValueKey("${message.messageId}${message.receipt}"),
              time: message.time,
              color:
                  Theme.of(context).colorScheme.primaryVariant.withOpacity(0.6),
            )
        ],
      );
    }
  }
}
