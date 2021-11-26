import 'package:equatable/equatable.dart';

import '../../../model/invitation_model.dart';
import '../../../model/invitee_model.dart';

class SentInvitationState extends Equatable {
  const SentInvitationState();

  @override
  List<Object?> get props => [];
}

class SentInvitationInitial extends SentInvitationState {}

class LoadingInvitees extends SentInvitationState {}

class InviteesLoaded extends SentInvitationState {
  final InviteeModel inviteeModel;
  final bool hasMore;

  const InviteesLoaded({required this.inviteeModel, this.hasMore = true});

  @override
  List<Object?> get props => [inviteeModel];
}

class InviteeLoadingFailed extends SentInvitationState {
  final String message;

  const InviteeLoadingFailed(this.message);
}

// For other actions performed such as invitation withdrawal action
class Withdrawing extends SentInvitationState {
  final int index;
  const Withdrawing(this.index);
}

class OtherInvitationAction extends SentInvitationState {}

class Withdrawed extends SentInvitationState {}

class WithdrawalFailed extends SentInvitationState {
  final int index;
  final Invitee invitee;

  const WithdrawalFailed({required this.index, required this.invitee});
}

// For Refresh
class RefreshingInvitees extends SentInvitationState {}

class Refreshing extends SentInvitationState {}

class InviteeRefreshFailed extends SentInvitationState {}
