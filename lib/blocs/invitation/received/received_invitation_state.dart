import 'package:equatable/equatable.dart';

import '../../../model/invitation_model.dart';
import '../../../model/inviter_model.dart';

class ReceivedInvitationState extends Equatable {
  const ReceivedInvitationState();

  @override
  List<Object?> get props => [];
}

class ReceivedInvitationInitial extends ReceivedInvitationState {}

class LoadingInviters extends ReceivedInvitationState {}

class InvitersLoaded extends ReceivedInvitationState {
  final InviterModel inviterModel;
  final bool hasMore;

  const InvitersLoaded({required this.inviterModel, this.hasMore = true});

  @override
  List<Object?> get props => [inviterModel];
}

class InviterLoadingFailed extends ReceivedInvitationState {
  final String message;

  const InviterLoadingFailed(this.message);
}

// For Refresh
class RefreshingInviters extends ReceivedInvitationState {}

class RefreshingInvitersLoading extends ReceivedInvitationState {}

class InviterRefreshFailed extends ReceivedInvitationState {}

class OtherReceivedAction extends ReceivedInvitationState {}

class Processing extends ReceivedInvitationState {
  final int index;
  const Processing(this.index);
}

class Ignored extends ReceivedInvitationState {}

class OtherActionFailed extends ReceivedInvitationState {
  final int index;
  final Inviter inviter;

  const OtherActionFailed({required this.index, required this.inviter});
}

class Accept extends ReceivedInvitationState {
  final Inviter inviter;
  final String fullName;

  const Accept({required this.inviter, required this.fullName});
}
