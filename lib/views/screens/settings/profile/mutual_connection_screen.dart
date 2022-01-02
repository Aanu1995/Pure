import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/views/widgets/custom_keep_alive.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/invitation_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/palette.dart';
import '../../../../utils/navigate.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/shimmers/loading_shimmer.dart';
import '../../../widgets/user_profile_provider.dart';
import '../../chats/messages/messages_screen.dart';
import 'profile_screen.dart';

class MutualConnectionsScreen extends StatelessWidget {
  final List<String> connections;
  const MutualConnectionsScreen({Key? key, required this.connections})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mutual Connections",
          style: const TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.custom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        physics: AlwaysScrollableScrollPhysics(),
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final connectorId = connections[index];
            return CustomKeepAlive(
              key: ValueKey<String>(connectorId),
              child: ProfileProvider(
                userId: connectorId,
                child: _ConnectorProfile(
                  connectorId: connectorId,
                  // only show separator if there is another item below
                  showSeparator: index < (connections.length - 1),
                ),
              ),
            );
          },
          childCount: connections.length,
          findChildIndexCallback: (Key key) {
            final ValueKey<String> valueKey = key as ValueKey<String>;
            final String data = valueKey.value;
            return connections.indexOf(data);
          },
        ),
      ),
    );
  }
}

class _ConnectorProfile extends StatelessWidget {
  final String connectorId;
  final bool showSeparator;
  const _ConnectorProfile(
      {Key? key, required this.connectorId, this.showSeparator = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSuccess) {
          final user = state.user;
          return Column(
            children: [
              ListTile(
                onTap: () => viewFullProfile(context, user),
                contentPadding: const EdgeInsets.fromLTRB(4, 10, 0, 10),
                horizontalTitleGap: 0.0,
                leading: Avartar(size: 40.0, imageURL: user.photoURL),
                title: Text(
                  user.fullName,
                  key: ValueKey(connectorId),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.about!.isEmpty ? "--" : user.about!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => onProfileTapped(context, user),
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Palette.tintColor,
                  ),
                ),
              ),
              if (showSeparator) const Divider(height: 0.0),
            ],
          );
        }
        return const SingleShimmer();
      },
    );
  }

  void viewFullProfile(BuildContext context, final PureUser user) {
    push(context: context, page: ProfileScreen(user: user));
  }

  void onProfileTapped(BuildContext context, PureUser user) {
    // gets the chatId using the id of the two users
    final chatId = InvitationModel.getInvitationId(
      user.id,
      CurrentUser.currentUserId,
    );
    push(
      context: context,
      rootNavigator: true,
      page: MessagesScreen(chatId: chatId, receipient: user),
    );
  }
}
