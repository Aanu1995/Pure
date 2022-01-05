import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitation_model.dart';
import '../../../model/inviter_model.dart';
import '../../../repositories/local_storage.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'received_invitation_state.dart';

class ReceivedInvitationCubit extends Cubit<ReceivedInvitationState> {
  final InvitationService invitationService;
  final LocalStorage? localStorage;
  ReceivedInvitationCubit({required this.invitationService, this.localStorage})
      : super(ReceivedInvitationInitial()) {
    _localStorage = localStorage ?? LocalStorageImpl();
  }

  late LocalStorage _localStorage;

  Future<void> loadInviters(String userId) async {
    InviterModel inviterModel = InviterModel(inviters: []);
    try {
      // load from local storage
      final data = await _localStorage
          .getData(GlobalUtils.receivedInvitationPrefKey) as List?;
      if (data != null) {
        final inviterList = _mapDataToModel(data);
        inviterModel = InviterModel(inviters: inviterList);
      }
      emit(InvitersLoaded(inviterModel: inviterModel));
    } catch (e) {
      emit(InviterLoadingFailed(ErrorMessages.generalMessage2));
    }
  }

// Preciely used when to update the UI after it is refreshed
  void updateNewInviters(InviterModel inviterModel) {
    emit(InvitersLoaded(
      inviterModel: inviterModel,
      hasMore: hasMore(inviterModel.inviters),
    ));
  }

  // Precisely used to update the UI when more inviters are fetched (pagination)
  void updateOldInviters(InviterModel inviterModel, bool hasMore) {
    final currentState = state;
    if (currentState is InvitersLoaded) {
      final totalInviters = [
        ...currentState.inviterModel.inviters.toList(),
        ...inviterModel.inviters.toList()
      ];
      final model = InviterModel(
        inviters: totalInviters,
        lastDoc: inviterModel.lastDoc,
      );
      emit(InvitersLoaded(inviterModel: model, hasMore: hasMore));
    }
  }

  void delete(int index) {
    final currentState = state;
    if (currentState is InvitersLoaded) {
      final inviterList = currentState.inviterModel.inviters.toList();
      // remove the invitee from the list
      inviterList.removeAt(index);

      emit(InvitersLoaded(
        inviterModel: InviterModel(
          inviters: inviterList,
          lastDoc: currentState.inviterModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  void addInviterBack(int index, Inviter invitee) {
    final currentState = state;
    if (currentState is InvitersLoaded) {
      final inviterList = currentState.inviterModel.inviters.toList();
      // remove the invitee from the list
      inviterList.insert(index, invitee);

      emit(InvitersLoaded(
        inviterModel: InviterModel(
          inviters: inviterList,
          lastDoc: currentState.inviterModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  /// Helper methods

  bool hasMore(List<Inviter> inviterList) {
    if (inviterList.isEmpty) return false;
    return inviterList.length % GlobalUtils.inviterListLimit == 0;
  }

  List<Inviter> _mapDataToModel(List data) {
    final inviterList = <Inviter>[];
    for (final inviterJson in data) {
      inviterList.add(Inviter.fromMap(inviterJson as Map<String, dynamic>));
    }

    return inviterList;
  }
}
