import 'package:equatable/equatable.dart';

import '../../../../model/pure_user_model.dart';

class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupMembers extends GroupState {
  final List<PureUser> members;

  const GroupMembers({required this.members});

  @override
  List<Object?> get props => [members];
}
