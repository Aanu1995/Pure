import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitation_model.dart';
import '../../../model/inviter_model.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'received_invitation_state.dart';

class LoadMoreInviterCubit extends Cubit<ReceivedInvitationState> {
  final InvitationService invitationService;
  LoadMoreInviterCubit(this.invitationService)
      : super(ReceivedInvitationInitial());

  Future<void> loadMoreInvitees(
      String userId, InviterModel inviterModel) async {
    emit(LoadingInviters());

    try {
      final result = await invitationService.loadMoreReceivedInvitationList(
          userId, inviterModel.lastDocs!);

      List<Inviter> newData = [
        ...inviterModel.inviters.toList(),
        ...result.inviters
      ];

      emit(InvitersLoaded(
        inviterModel: InviterModel(
          inviters: newData,
          lastDocs: result.lastDocs,
        ),
        hasMore: hasMore(result.inviters),
      ));
    } on NetworkException catch (e) {
      emit(InviterLoadingFailed(e.message!));
    } on ServerException catch (e) {
      emit(InviterLoadingFailed(e.message!));
    } catch (_) {
      emit(InviterLoadingFailed(ErrorMessages.generalMessage2));
    }
  }

  Future<void> refresh(String userId, {bool showIndicator = false}) async {
    if (showIndicator) {
      emit(RefreshingInviters());
    } else {
      emit(RefreshingInvitersLoading());
    }

    try {
      final result = await invitationService.getReceivedInvitationList(userId);

      emit(InvitersLoaded(
        inviterModel: result,
        hasMore: hasMore(result.inviters),
      ));
    } on NetworkException catch (_) {
      emit(InviterRefreshFailed());
    } on ServerException catch (_) {
      emit(InviterRefreshFailed());
    } catch (_) {
      emit(InviterRefreshFailed());
    }
  }

  bool hasMore(List<Inviter> inviterList) {
    if (inviterList.isEmpty) {
      return false;
    }
    return inviterList.length % GlobalUtils.inviterListLimit == 0;
  }
}

class OtherReceivedActionsCubit extends Cubit<ReceivedInvitationState> {
  final InvitationService invitationService;
  OtherReceivedActionsCubit(this.invitationService)
      : super(OtherReceivedAction());

  Future<void> ignoreInvitation(int index, Inviter inviter) async {
    emit(Processing(index));

    try {
      await invitationService.withdrawInvitation(inviter.invitationId);

      emit(Ignored());
    } on NetworkException catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    } on ServerException catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    } catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    }
  }

  Future<void> acceptInvitation(int index, String name, Inviter inviter) async {
    emit(Processing(index));

    try {
      await invitationService.acceptInvitation(inviter.invitationId);

      emit(Accept(inviter: inviter, fullName: name));
    } on NetworkException catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    } on ServerException catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    } catch (_) {
      emit(OtherActionFailed(index: index, inviter: inviter));
    }
  }
}
