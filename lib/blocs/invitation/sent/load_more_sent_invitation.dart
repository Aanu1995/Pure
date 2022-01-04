import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitee_model.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'sent_invitations_state.dart';

class LoadMoreInviteeCubit extends Cubit<SentInvitationState> {
  final InvitationService invitationService;
  LoadMoreInviteeCubit(this.invitationService) : super(SentInvitationInitial());

  Future<void> loadMoreInvitees(String userId, DocumentSnapshot lastDoc) async {
    emit(LoadingInvitees());

    try {
      final result =
          await invitationService.loadMoreSentInvitationList(userId, lastDoc);

      emit(InviteesLoaded(
        inviteeModel: result,
        hasMore: hasMore(result.invitees),
      ));
    } on NetworkException catch (e) {
      emit(InviteeLoadingFailed(e.message!));
    } on ServerException catch (e) {
      emit(InviteeLoadingFailed(e.message!));
    } catch (_) {
      emit(InviteeLoadingFailed(ErrorMessages.generalMessage2));
    }
  }

  bool hasMore(List<Invitee> inviteeList) {
    if (inviteeList.isEmpty) {
      return false;
    }
    return inviteeList.length % GlobalUtils.inviteeListLimit == 0;
  }
}

class RefreshInviteeCubit extends Cubit<SentInvitationState> {
  final InvitationService invitationService;
  RefreshInviteeCubit(this.invitationService) : super(SentInvitationInitial());

  Future<void> refresh(String userId, {bool showIndicator = false}) async {
    if (showIndicator) {
      emit(RefreshingInvitees());
    } else {
      emit(Refreshing());
    }

    try {
      final result = await invitationService.refreshInvitees(userId);

      emit(InviteesLoaded(inviteeModel: result));
    } on NetworkException catch (_) {
      emit(InviteeRefreshFailed());
    } on ServerException catch (_) {
      emit(InviteeRefreshFailed());
    } catch (_) {
      emit(InviteeRefreshFailed());
    }
  }
}

class OtherActionsInvitationCubit extends Cubit<SentInvitationState> {
  final InvitationService invitationService;
  OtherActionsInvitationCubit(this.invitationService)
      : super(OtherInvitationAction());

  // takes the index of the item in the list and the invitee model
  Future<void> withdrawInvitation(int index, Invitee invitee) async {
    emit(Withdrawing(index));

    try {
      await invitationService.withdrawInvitation(invitee.invitationId);

      emit(Withdrawed());
    } on NetworkException catch (_) {
      emit(WithdrawalFailed(index: index, invitee: invitee));
    } on ServerException catch (_) {
      emit(WithdrawalFailed(index: index, invitee: invitee));
    } catch (_) {
      emit(WithdrawalFailed(index: index, invitee: invitee));
    }
  }
}
