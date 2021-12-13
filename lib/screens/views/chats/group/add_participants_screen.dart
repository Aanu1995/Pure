import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../widgets/snackbars.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_theme.dart';
import '../../../../utils/app_utils.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/message_widget.dart';
import '../../../widgets/user_profile_provider.dart';
import 'friend_profile.dart';

class AddNewParticipant extends StatefulWidget {
  final ChatModel chat;
  final List<String> groupMembers;
  final ValueChanged<List<PureUser>> onNewParticipantsAdded;
  const AddNewParticipant({
    Key? key,
    required this.chat,
    required this.groupMembers,
    required this.onNewParticipantsAdded,
  }) : super(key: key);

  @override
  State<AddNewParticipant> createState() => _AddNewParticipantState();
}

class _AddNewParticipantState extends State<AddNewParticipant> {
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
      friendsUserId.removeWhere((conn) => widget.groupMembers.contains(conn));
    }
  }

  // update as state in Bloc Listener updates
  void addMemberStateListener(BuildContext context, ParticipantState state) {
    if (state is AddingParticipant) {
      EasyLoading.show(status: 'Adding...');
    } else if (state is NewParticipant) {
      try {
        EasyLoading.dismiss();
        widget.onNewParticipantsAdded.call(state.newMembers);
        Navigator.pop(context);
      } catch (e) {}
    } else if (state is NewParticipantFailed) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message);
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
                BlocBuilder<AddParticipantCubit, GroupState>(
                  builder: (context, state) {
                    return TextButton(
                      onPressed:
                          state is GroupMembers && state.members.isNotEmpty
                              ? () => addNewAppliacants(
                                    widget.chat.chatId,
                                    state.members,
                                  )
                              : null,
                      child: Text(
                        "Add",
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
        body: BlocListener<ParticipantCubit, ParticipantState>(
          listener: addMemberStateListener,
          child: Column(
            children: [
              NewApplicantProfile(),
              Divider(),
              Expanded(
                child: BlocBuilder<SearchFriendBloc, SearchFriendState>(
                  builder: (context, state) {
                    if (state is SearchFriendSuccess &&
                        state.query.isNotEmpty) {
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
                      key: ValueKey(friendsUserId),
                      connections: friendsUserId,
                    );
                  },
                ),
              ),
            ],
          ),
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

  void addNewAppliacants(String chatId, List<PureUser> members) {
    context.read<ParticipantCubit>().addGroupMembers(chatId, members);
  }
}

class NewApplicantProfile extends StatelessWidget {
  const NewApplicantProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddParticipantCubit, GroupState>(
      builder: (context, memberState) {
        if (memberState is GroupMembers && memberState.members.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SizedBox(
              width: 1.0.sw,
              height: 100.0,
              child: ListView.builder(
                itemCount: memberState.members.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final user = memberState.members[index];
                  return SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Avartar2(size: 30.0, imageURL: user.photoURL),
                              const SizedBox(height: 8.0),
                              Text(
                                user.fullName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -10.0,
                          right: -4.0,
                          child: IconButton(
                            onPressed: () => context
                                .read<AddParticipantCubit>()
                                .removeMember(user),
                            icon: CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                              child: Icon(
                                Icons.close,
                                size: 14.0,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
        return Offstage();
      },
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
                builder: (context, user) {
                  return BlocBuilder<AddParticipantCubit, GroupState>(
                    builder: (context, groupState) {
                      if (groupState is GroupMembers) {
                        final isMember =
                            isUserAMember(groupState.members, user);

                        return Checkbox(
                          value: isMember,
                          activeColor: Palette.tintColor,
                          shape: CircleBorder(),
                          onChanged: (active) => active!
                              ? context
                                  .read<AddParticipantCubit>()
                                  .addMember(user)
                              : context
                                  .read<AddParticipantCubit>()
                                  .removeMember(user),
                        );
                      }
                      return Offstage();
                    },
                  );
                },
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

  bool isUserAMember(List<PureUser> members, PureUser user) {
    return members.firstWhereOrNull((element) => element.id == user.id) != null;
  }
}
