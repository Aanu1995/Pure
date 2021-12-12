import 'package:equatable/equatable.dart';
import 'package:pure/model/pure_user_model.dart';

class NewParticipantState extends Equatable {
  const NewParticipantState();

  @override
  List<Object?> get props => [];
}

class ParticipantInitial extends NewParticipantState {}

class AddingParticipant extends NewParticipantState {}

class NewParticipant extends NewParticipantState {
  final List<PureUser> newMembers;

  const NewParticipant({required this.newMembers});

  @override
  List<Object?> get props => [newMembers];
}

class NewParticipantFailed extends NewParticipantState {
  final String message;

  const NewParticipantFailed(this.message);
}
