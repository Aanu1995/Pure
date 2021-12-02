import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/pure_user_model.dart';
import 'create_group_state.dart';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit() : super(GroupMembers(members: []));

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
