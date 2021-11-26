import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../blocs/chats/messages/message_cubit.dart';
import '../../../../../model/chat/message_model.dart';

class TrailingText extends StatelessWidget {
  final String time;
  final Receipt? receipt;
  final double? width;
  final Color? color;
  const TrailingText(
      {Key? key, required this.time, this.width, this.receipt, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: color, fontSize: 11.0),
            ),
            if (receipt != null) const SizedBox(width: 2.0),
            if (receipt == Receipt.Pending)
              Icon(Icons.query_builder_outlined, size: 14.0, color: color)
            else if (receipt == Receipt.Sent)
              Icon(Icons.done, size: 16.0, color: color)
            else if (receipt == Receipt.Delivered)
              Icon(Icons.done_all_outlined, size: 14.0, color: color)
            else if (receipt == Receipt.Read)
              Icon(
                Icons.done_all_outlined,
                size: 14.0,
                color: Theme.of(context).colorScheme.surface,
              ),
          ],
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  const TextWidget({Key? key, required this.text, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return Offstage();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: color ?? Theme.of(context).colorScheme.secondary,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

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
              padding: const BubbleEdges.fromLTRB(8, 6, 8, 4),
              stick: true,
              nip: hideNip ? null : BubbleNip.rightTop,
              color: Theme.of(context).primaryColor,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  TextWidget(
                    key: ValueKey("${message.messageId}${message.text}"),
                    text: message.text,
                  ),
                  TrailingText(
                    key: ValueKey("${message.messageId}${message.receipt}"),
                    time: message.time,
                    receipt: message.receipt,
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.6),
                  )
                ],
              ),
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
          padding: const BubbleEdges.fromLTRB(8, 6, 8, 4),
          stick: true,
          nip: hideNip ? null : BubbleNip.leftTop,
          color: Theme.of(context).colorScheme.secondary,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              TextWidget(
                key: ValueKey("${message.messageId}${message.text}"),
                text: message.text,
                color: Theme.of(context).colorScheme.primaryVariant,
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

class FailedToDeliverMessageWidget extends StatelessWidget {
  final String chatId;
  const FailedToDeliverMessageWidget({Key? key, required this.chatId})
      : super(key: key);

  static final _style = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.red,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text Message
        Padding(
          padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
          child: Text("Not Delivered", style: _style),
        ),

        // Try again Button
        InkWell(
          borderRadius: BorderRadius.circular(500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 8, 10),
            child: Icon(Icons.refresh),
          ),
          onTap: () => context.read<MessageCubit>().resendMessages(chatId),
        ),
      ],
    );
  }
}
