import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/attachment_model.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_theme.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/avatar.dart';
import '../../../photo_view_screen.dart';
import '../../../settings/profile/profile_screen.dart';
import 'message_inbox_widget.dart';
import 'messages_body.dart';

class MessageAppBarTitle extends StatelessWidget {
  final String chatId;
  final PureUser receipient;
  final bool hasPresenceActivated;
  const MessageAppBarTitle({
    Key? key,
    required this.chatId,
    required this.receipient,
    this.hasPresenceActivated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewFullProfile(context, receipient),
      child: Row(
        children: [
          Avartar(
            size: 22,
            ringSize: 0.8,
            imageURL: receipient.photoURL,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipient.fullName,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.5,
                    fontFamily: Palette.sanFontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasPresenceActivated)
                  BlocBuilder<UserPresenceCubit, UserPresenceState>(
                    builder: (context, state) {
                      final status = state is UserPresenceSuccess &&
                          state.presence.isOnline;
                      if (status)
                        return Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            "Online",
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryVariant
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                              fontSize: 13.0,
                              fontFamily: Palette.sanFontFamily,
                              letterSpacing: 0.25,
                            ),
                          ),
                        );
                      return Offstage();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void viewFullProfile(BuildContext context, PureUser user) {
    push(
      context: context,
      page: ProfileScreen(user: user, hideConnectionStatus: true),
    );
  }
}

class MessageBody extends StatelessWidget {
  final String chatId;
  final String receipientName;
  const MessageBody(
      {Key? key, required this.chatId, required this.receipientName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageCubit, MessageState>(
      listenWhen: (prev, current) =>
          prev is MessageInitial && current is MessagesLoaded,
      listener: (context, state) => context
          .read<NewMessagesCubit>()
          .updateOnNewMessages(chatId, CurrentUser.currentUserId),
      child: Column(
        children: [
          // Messages
          Expanded(
            child: Messagesbody(
              chatId: chatId,
              firstName: receipientName,
              onSentButtonPressed: (final message) =>
                  sendMessage(context, message),
            ),
          ),
          // Message Input Box
          AnimatedPadding(
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MessageInputBox(
              chatId: chatId,
              onSentButtonPressed: (final message) =>
                  sendMessage(context, message),
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(final BuildContext context, final MessageModel message) {
    context.read<MessageCubit>().sendTextMessageOnly(chatId, message);
  }
}

class FileWidget extends StatelessWidget {
  final List<Attachment> attachments;
  const FileWidget({Key? key, required this.attachments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attachments.first is ImageAttachment) {
      if (attachments.length <= 1) {
        final newAttachment = attachments.first as ImageAttachment;
        if (newAttachment.localFile != null)
          return ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.file(
              newAttachment.localFile!,
              width: newAttachment.width.toDouble(),
            ),
          );
        else
          return Hero(
            tag: newAttachment.fileURL!,
            child: InkWell(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: newAttachment.fileURL!,
                  width: newAttachment.width.toDouble(),
                  placeholder: (context, _) {
                    return AspectRatio(
                      aspectRatio: newAttachment.width.toDouble() /
                          newAttachment.height.toDouble(),
                      child: Container(color: newAttachment.color),
                    );
                  },
                  errorWidget: (context, url, dynamic _) {
                    return AspectRatio(
                      aspectRatio: newAttachment.width.toDouble() /
                          newAttachment.height.toDouble(),
                      child: Container(color: newAttachment.color),
                    );
                  },
                ),
              ),
              onTap: () => push(
                context: context,
                page: ViewFullPhoto(
                  tag: newAttachment.fileURL!,
                  color: newAttachment.color,
                  imageURL: newAttachment.fileURL!,
                ),
              ),
            ),
          );
      }
    }
    return Offstage();
  }
}
