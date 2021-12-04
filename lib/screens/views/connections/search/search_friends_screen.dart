import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/model/pure_user_model.dart';
import 'package:pure/utils/app_utils.dart';

import '../../../../blocs/bloc.dart';
import '../../../widgets/snackbars.dart';
import '../tabs/connections/connectors_list.dart';
import '../../../widgets/message_widget.dart';

class SearchFriends extends StatefulWidget {
  const SearchFriends({Key? key}) : super(key: key);

  @override
  State<SearchFriends> createState() => _SearchFriendsState();
}

class _SearchFriendsState extends State<SearchFriends> {
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
    addCurrentConnectors();
  }

  void addCurrentConnectors() {
    final connectorState = BlocProvider.of<ConnectorCubit>(context).state;
    if (connectorState is ConnectionsLoaded) {
      context.read<SearchFriendBloc>().add(LoadAvailableFriends(
          friends: connectorState.connectionModel.connectors));
    }
  }

  void otherActionListener(BuildContext context, ConnectorState state) {
    if (state is RemovingConnector) {
      context.read<SearchFriendBloc>().add(DeleteFriend(index: state.index));
    } else if (state is ConnectorRemoved) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user.copyWith(
          isRemovedConnection: true,
          identifier: state.connectorId,
        );
        BlocProvider.of<AuthCubit>(context).update(currentUser);
        context.read<ConnectorCubit>().deleteItemWithId(state.connectorId);
      }
    } else if (state is ConnectorRemovalFailed) {
      showFailureFlash(
        context,
        "Failed to remove connection",
        backgroundColor: Color(0xFF04192F),
        position: FlashPosition.top,
      );
      context
          .read<SearchFriendBloc>()
          .add(AddFriend(index: state.index, friend: state.connector));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtherActionsConnectionCubit, ConnectorState>(
      listener: otherActionListener,
      child: Scaffold(
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
                const SizedBox(width: 16.0),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Divider(height: 1.2, thickness: 1.2),
            Expanded(
              child: BlocConsumer<SearchFriendBloc, SearchFriendState>(
                listener: (context, state) {
                  if (state is SearchFriendSuccess && state.query.isEmpty)
                    addCurrentConnectors();
                },
                builder: (context, state) {
                  if (state is SearchFriendSuccess) {
                    final connectorList = state.friends;
                    if (connectorList.isEmpty)
                      return const MessageDisplay();
                    else
                      return ConnectorList(
                        key: ObjectKey(connectorList),
                        connectors: connectorList,
                      );
                  } else if (state is SearchFriendFailure) {
                    return MessageDisplay(
                      fontSize: 18.0,
                      title: state.message,
                      description: "Please check your internet connection",
                    );
                  }
                  return Offstage();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
