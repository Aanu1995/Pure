import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/screens/views/chats/messages/messages_screen.dart';
import 'package:pure/utils/navigate.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/app_enum.dart';
import '../../../../../model/invitation_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_theme.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final PureUser viewer;

  const ConnectionStatusWidget({Key? key, required this.viewer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, current) =>
          (prev is Authenticated && current is Authenticated) &&
          prev.user.sentCounter != current.user.sentCounter,
      builder: (context, state) {
        if (state is Authenticated) {
          final status = state.user.checkConnectionAction(viewer.id);
          if (status == ConnectionAction.MESSAGE) {
            // connected
            return IconButton(
              onPressed: () => onProfileTapped(context, viewer),
              padding: EdgeInsets.only(left: 8.0, right: 4.0),
              icon: Icon(
                Icons.chat_outlined,
                color: Palette.tintColor,
              ),
            );
          } else if (status == ConnectionAction.PENDING) {
            // pending
            return Padding(
              padding: EdgeInsets.only(left: 8.0, right: 4.0),
              child: Icon(
                Icons.check_circle_outline,
                color: Palette.tintColor,
              ),
            );
          } else if (status == ConnectionAction.CONNECT) {
            if (viewer.isPrivate) return Offstage();

            // Not connected
            return IconButton(
              onPressed: () => sendConnectionRequest(context, viewer.id),
              padding: EdgeInsets.only(left: 8.0, right: 4.0),
              icon: Icon(
                Icons.person_add_alt_1_outlined,
                color: Palette.tintColor,
              ),
            );
          }
        }
        return Offstage();
      },
    );
  }

  void sendConnectionRequest(BuildContext context, String receiverId) {
    final state = BlocProvider.of<SendInvitationCubit>(context).state;
    if (state is! SendingInvitation) {
      final data = InvitationModel(
          senderId: CurrentUser.currentUserId, receiverId: receiverId);
      BlocProvider.of<SendInvitationCubit>(context)
          .sendInvitation(data.toMap());
    }
  }

  void onProfileTapped(BuildContext context, PureUser user) {
    // gets the chatId using the id of the two users
    final chatId = InvitationModel.getInvitationId(
      user.id,
      CurrentUser.currentUserId,
    );
    push(
      context: context,
      page: MessagesScreen(chatId: chatId, receipient: user),
    );
  }
}
