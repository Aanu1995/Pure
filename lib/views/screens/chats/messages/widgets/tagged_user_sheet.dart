import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/chat_utils.dart';
import 'tagged_user_profile.dart';

class TaggedUserSheet extends StatelessWidget {
  final ValueNotifier<String?> userTaggingNotifier;
  final TextEditingController controller;
  const TaggedUserSheet({
    Key? key,
    required this.controller,
    required this.userTaggingNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupMembers) {
            return ValueListenableBuilder<String?>(
              valueListenable: userTaggingNotifier,
              builder: (context, value, _) {
                if (value == null) return Offstage();
                final members = state.members.toList();
                final users = getTaggedUsers(members, value);
                if (users.isEmpty)
                  return Offstage();
                else
                  return TaggedUsers(
                    members: users,
                    onUserPressed: (username) =>
                        onTaggedUserSelected(value, username),
                  );
              },
            );
          }
          return Offstage();
        },
      ),
    );
  }

  List<PureUser> getTaggedUsers(List<PureUser> members, String value) {
    members.removeWhere((element) => element.id == CurrentUser.currentUserId);
    return members.toList().where((member) {
      return member.username.toLowerCase().contains(value.toLowerCase());
    }).toList();
  }

  void onTaggedUserSelected(String input, String selected) {
    replaceUserTagOnSelected(controller, input, selected);
  }
}
