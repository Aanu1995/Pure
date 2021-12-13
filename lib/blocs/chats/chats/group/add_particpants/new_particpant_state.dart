import 'package:equatable/equatable.dart';

import '../../../../../model/pure_user_model.dart';

class ParticipantState extends Equatable {
  const ParticipantState();

  @override
  List<Object?> get props => [];
}

class ParticipantInitial extends ParticipantState {}

class AddingParticipant extends ParticipantState {}

class NewParticipant extends ParticipantState {
  final List<PureUser> newMembers;

  const NewParticipant({required this.newMembers});

  @override
  List<Object?> get props => [newMembers];
}

class NewParticipantFailed extends ParticipantState {
  final String message;

  const NewParticipantFailed(this.message);
}

class RemovingParticipant extends ParticipantState {
  final PureUser participant;

  const RemovingParticipant(this.participant);
}

class AddingAdmin extends ParticipantState {
  final String memberId;

  const AddingAdmin(this.memberId);
}

class RemovingAdmin extends ParticipantState {
  final String memberId;

  const RemovingAdmin(this.memberId);
}

class OperationCompleted extends ParticipantState {}

class ParticipantRemoved extends ParticipantState {
  final PureUser participant;

  const ParticipantRemoved(this.participant);
}

class FailedToRemoveParticipant extends ParticipantState {
  final PureUser participant;
  final int index;

  const FailedToRemoveParticipant(this.index, this.participant);
}

class ExitingGroup extends ParticipantState {}

class GroupExited extends ParticipantState {
  final String chatId;

  const GroupExited(this.chatId);
}

class FailedToExitGroup extends ParticipantState {
  final String message;

  const FailedToExitGroup(this.message);
}
