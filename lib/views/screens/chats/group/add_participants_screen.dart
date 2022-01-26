import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/chat/message_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_utils.dart';
import '../../../widgets/message_widget.dart';
import '../../../widgets/snackbars.dart';
import 'widget/new_applicant_profile.dart';
import 'widget/user_connection_list.dart';

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
  late PureUser currentUser;
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> friendsUserId = [];

  @override
  void initState() {
    super.initState();
    initialize();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }
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
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                        return UserConnectionList(connections: friends);
                      }
                    } else if (state is SearchFriendFailure) {
                      return MessageDisplay(
                        fontSize: 18.0,
                        title: state.message,
                        description: "Please check your internet connection",
                      );
                    }
                    return UserConnectionList(
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
    final message = MessageModel.notifyMessage(
      "added",
      currentUser.id,
      currentUser.getAtUsername,
      object: members.toList().map((e) => e.getAtUsername).toList().join(","),
    );
    context.read<ParticipantCubit>().addGroupMembers(chatId, members, message);
  }
}
