import 'package:equatable/equatable.dart';

import '../../../../model/pure_user_model.dart';

class CreateGroupState extends Equatable {
  const CreateGroupState();

  @override
  List<Object?> get props => [];
}

class GroupMembers extends CreateGroupState {
  final List<PureUser> members;

  const GroupMembers({required this.members});

  @override
  List<Object?> get props => [members];
}
