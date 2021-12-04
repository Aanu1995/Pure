import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/pure_user_model.dart';
import 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupMembers(members: []));

  void addMember(PureUser user) {
    final currentState = state;

    if (currentState is GroupMembers) {
      final members = currentState.members.toList();
      members.add(user);
      emit(GroupMembers(members: members));
    }
  }

  void removeMember(PureUser user) {
    final currentState = state;

    if (currentState is GroupMembers) {
      final members = currentState.members.toList();
      members.removeWhere((member) => member.id == user.id);
      emit(GroupMembers(members: members));
    }
  }
}
