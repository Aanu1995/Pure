import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/screens/views/chats/new_group/create_group_screen.dart';
import 'package:pure/services/chat/chat_service.dart';
import 'package:pure/utils/navigate.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_utils.dart';
import '../../../widgets/message_widget.dart';
import '../../../widgets/user_profile_provider.dart';
import 'friend_profile.dart';

class SearchFriendChat extends StatefulWidget {
  const SearchFriendChat({Key? key}) : super(key: key);

  @override
  State<SearchFriendChat> createState() => _SearchFriendChatState();
}

class _SearchFriendChatState extends State<SearchFriendChat> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> friendsUserId = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void initialize() {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (authState is Authenticated) {
      friendsUserId = getConnections(authState.user.connections!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.maxFinite, 60.0),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.west, color: Colors.grey.shade700),
                ),
                Expanded(
                  child: CupertinoSearchTextField(
                    focusNode: _focusNode,
                    controller: _searchController,
                    autofocus: true,
                    prefixInsets:
                        const EdgeInsetsDirectional.fromSTEB(6, 0, 8, 4),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.primaryVariant,
                    ),
                    onChanged: search,
                  ),
                ),
                const SizedBox(width: 8.0),
                BlocBuilder<CreateGroupCubit, CreateGroupState>(
                  builder: (context, state) {
                    return TextButton(
                      onPressed:
                          state is GroupMembers && state.members.isNotEmpty
                              ? () => pushToCreateGroupScreen(context)
                              : null,
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.05,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            MemberProfile(),
            Divider(),
            Expanded(
              child: BlocBuilder<SearchFriendBloc, SearchFriendState>(
                builder: (context, state) {
                  if (state is SearchFriendSuccess && state.query.isNotEmpty) {
                    final connectorList = state.friends;
                    if (connectorList.isEmpty)
                      return const MessageDisplay();
                    else {
                      final friends =
                          state.friends.map((e) => e.connectorId).toList();
                      return _Connections(connections: friends);
                    }
                  } else if (state is SearchFriendFailure) {
                    return MessageDisplay(
                      fontSize: 18.0,
                      title: state.message,
                      description: "Please check your internet connection",
                    );
                  }
                  return _Connections(
                    key: ObjectKey(friendsUserId),
                    connections: friendsUserId,
                  );
                },
              ),
            ),
          ],
        ));
  }

  void search(String query) {
    context.read<SearchFriendBloc>().add(
          SearchFriendTextChanged(
            text: query,
            friendIds: friendsUserId,
            currentUserId: CurrentUser.currentUserId,
          ),
        );
  }

  void pushToCreateGroupScreen(BuildContext context) {
    push(
      context: context,
      page: BlocProvider(
        create: (_) => GroupChatCubit(ChatServiceImp()),
        child: BlocProvider<CreateGroupCubit>.value(
          value: context.read<CreateGroupCubit>(),
          child: CreateGroupScreen(),
        ),
      ),
    );
  }
}

class _Connections extends StatelessWidget {
  final List<String> connections;
  const _Connections({Key? key, required this.connections}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final friendId = connections[index];

          return KeepAlive(
            key: ValueKey<String>(friendId),
            keepAlive: true,
            child: ProfileProvider(
              key: ValueKey(friendId),
              userId: friendId,
              child: ConnectionProfile(
                key: ValueKey(friendId),
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
    );
  }
}
