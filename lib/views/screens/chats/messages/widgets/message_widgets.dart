import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:collection/collection.dart';
import 'package:pure/utils/navigate.dart';
import 'package:pure/views/screens/settings/profile/profile_screen.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/attachment_model.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../../utils/file_utils.dart';
import '../../../../../utils/palette.dart';

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
        padding: const EdgeInsets.only(left: 8.0, right: 2.0),
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

class TrailingDocText extends StatelessWidget {
  final String time;
  final Receipt? receipt;
  final double? width;
  final Color? color;
  final Attachment attachment;
  const TrailingDocText({
    Key? key,
    required this.time,
    this.width,
    this.receipt,
    this.color,
    required this.attachment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${getStadardFileSize(attachment.size)} . ${attachment.fileExtension}",
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: color, fontSize: 11.0),
          ),
          Spacer(),
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
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  const TextWidget({Key? key, required this.text, this.color})
      : super(key: key);

  final _style = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    fontFamily: Palette.sanFontFamily,
  );

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return Offstage();
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      child: SelectableLinkify(
        text: text,
        style: _style.copyWith(
          color: color ?? Theme.of(context).colorScheme.secondary,
        ),
        textScaleFactor: null,
        linkifiers: const [
          UrlLinkifier(),
          EmailLinkifier(),
          UserTagLinkifier()
        ],
        options: LinkifyOptions(humanize: false),
        linkStyle: _style.copyWith(color: Colors.blueAccent),
        onOpen: (link) => openLink(context, link.url),
      ),
    );
  }

  void openLink(BuildContext context, String link) {
    if (link.startsWith("@")) {
      final state = BlocProvider.of<GroupCubit>(context).state;
      if (state is GroupMembers) {
        final members = state.members.toList();
        final user = members.firstWhereOrNull(
            (element) => element.username == link.replaceAll("@", ""));
        if (user != null) {
          push(context: context, page: ProfileScreen(user: user));
        }
      }
    } else {
      launchIfCan(context, link);
    }
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
          onTap: () =>
              context.read<MessageCubit>().resendFailedMessages(chatId),
        ),
      ],
    );
  }
}
