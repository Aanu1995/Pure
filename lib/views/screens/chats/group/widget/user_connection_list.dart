import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/palette.dart';
import '../../../../widgets/custom_keep_alive.dart';
import '../../../../widgets/user_profile_provider.dart';
import '../friend_profile.dart';

class UserConnectionList extends StatelessWidget {
  final List<String> connections;
  const UserConnectionList({Key? key, required this.connections})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final friendId = connections[index];

          return CustomKeepAlive(
            key: ValueKey<String>(friendId),
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
