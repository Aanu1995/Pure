import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/views/widgets/custom_keep_alive.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/connection_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/palette.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/avatar.dart';
import '../../../../widgets/shimmers/loading_shimmer.dart';
import '../../../../widgets/user_profile_provider.dart';
import '../../../chats/messages/messages_screen.dart';
import '../../../settings/profile/profile_screen.dart';
import '../../widgets/load_more.dart';

class ConnectorList extends StatelessWidget {
  final List<Connector> connectors;
  final ScrollController? controller;
  final void Function()? onFetchMorePressed;
  const ConnectorList(
      {Key? key,
      required this.connectors,
      this.onFetchMorePressed,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      controller: controller,
      padding: EdgeInsets.all(0),
      physics: AlwaysScrollableScrollPhysics(),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (connectors.length == index)
            return LoadMoreConnectors(onTap: onFetchMorePressed);
          else {
            final connector = connectors[index];
            return CustomKeepAlive(
              key: ValueKey<String>(connector.connectionId),
              child: ProfileProvider(
                userId: connector.connectorId,
                child: _ConnectorProfile(
                  connector: connector,
                  itemIndex: index,
                  // only show separator if there is another item below
                  showSeparator: index < (connectors.length - 1),
                ),
              ),
            );
          }
        },
        childCount:
            controller != null ? connectors.length + 1 : connectors.length,
        findChildIndexCallback: (Key key) {
          final ValueKey<String> valueKey = key as ValueKey<String>;
          final String data = valueKey.value;
          return connectors.map((e) => e.connectionId).toList().indexOf(data);
        },
      ),
    );
  }
}

class _ConnectorProfile extends StatelessWidget {
  final Connector connector;
  final int itemIndex;
  final bool showSeparator;
  const _ConnectorProfile({
    Key? key,
    required this.connector,
    required this.itemIndex,
    this.showSeparator = false,
  }) : super(key: key);

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
                  key: ValueKey(connector.connectionId),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                subtitle: Column(
                  key: ValueKey(connector.connectionId),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                    const SizedBox(height: 4.0),
                    Text(
                      "Connected ${getFormattedTime(connector.connectionDate!)}",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 100.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        key: ValueKey(connector.connectionId),
                        onPressed: () => onRemovedConnectionPressed(
                          context,
                          itemIndex,
                          user.fullName,
                          connector,
                        ),
                        padding: const EdgeInsets.only(left: 4.0),
                        icon: const Icon(
                          Icons.person_remove_outlined,
                          color: Colors.grey,
                          size: 24.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            onProfileTapped(context, connector, user),
                        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                        icon: Icon(
                          Icons.chat_outlined,
                          color: Palette.tintColor,
                        ),
                      ),
                    ],
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

  Future<void> onRemovedConnectionPressed(
    BuildContext context,
    int index,
    String fullName,
    Connector connector,
  ) async {
    final state = context.read<OtherActionsConnectionCubit>().state;
    if (state is! RemovingConnector) {
      final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Remove connection?',
        message: "Would you like to remove $fullName from "
            "your connections?",
        okLabel: "Remove",
        isDestructiveAction: true,
      );

      if (result == OkCancelResult.ok) {
        context
            .read<OtherActionsConnectionCubit>()
            .removeConnection(index, connector);
      }
    }
  }

  void onProfileTapped(
    BuildContext context,
    Connector connector,
    PureUser user,
  ) {
    push(
      context: context,
      page: MessagesScreen(chatId: connector.connectionId, receipient: user),
    );
  }
}
