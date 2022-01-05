import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitation_model.dart';
import '../../../model/invitee_model.dart';
import '../../../repositories/local_storage.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'sent_invitations_state.dart';

class SentInvitationCubit extends Cubit<SentInvitationState> {
  final InvitationService invitationService;
  final LocalStorage? localStorage;
  SentInvitationCubit({required this.invitationService, this.localStorage})
      : super(SentInvitationInitial()) {
    _localStorage = localStorage ?? LocalStorageImpl();
  }

  late LocalStorage _localStorage;
  StreamSubscription<InviteeModel>? _subscription;

  Future<void> loadInvitees(String userId) async {
    // load data from local storage first
    await _loadDataFromLocalStorage();
    loadDataFromRemoteStorage(userId);
  }

  Future<void> _loadDataFromLocalStorage() async {
    InviteeModel inviteeModel = InviteeModel(invitees: []);
    try {
      // load from local storage
      final data = await _localStorage
          .getData(GlobalUtils.sentInvitationPrefKey) as List?;
      if (data != null) {
        final inviteeList = _mapDataToModel(data);
        inviteeModel = InviteeModel(invitees: inviteeList);
      }
      emit(InviteesLoaded(inviteeModel: inviteeModel));
    } catch (e) {
      emit(InviteeLoadingFailed(ErrorMessages.generalMessage2));
      ;
    }
  }

  void loadDataFromRemoteStorage(String userId) {
    try {
      _subscription?.cancel();
      _subscription = invitationService
          .getSentInvitationList(userId)
          .listen((inviteeModel) {
        emit(InviteesLoaded(inviteeModel: inviteeModel));
      });
    } catch (_) {
      final currentState = state;
      if (currentState is! InviteesLoaded)
        emit(InviteeLoadingFailed(ErrorMessages.generalMessage2));
    }
  }

  // Preciely used when to update the UI after it is refreshed
  void updateNewInvitees(InviteeModel inviteeModel) {
    emit(InviteesLoaded(
      inviteeModel: inviteeModel,
      hasMore: hasMore(inviteeModel.invitees),
    ));
  }

  // Precisely used to update the UI when more invitees are fetched (pagination)
  void updateOldInvitees(InviteeModel inviteeModel, bool hasMore) {
    final currentState = state;
    if (currentState is InviteesLoaded) {
      final totalInvitees = [
        ...currentState.inviteeModel.invitees.toList(),
        ...inviteeModel.invitees.toList()
      ];
      final model = InviteeModel(
        invitees: totalInvitees,
        lastDoc: inviteeModel.lastDoc,
      );
      emit(InviteesLoaded(inviteeModel: model, hasMore: hasMore));
    }
  }

  void delete(int index) {
    final currentState = state;
    if (currentState is InviteesLoaded) {
      final inviteeList = currentState.inviteeModel.invitees.toList();
      // remove the invitee from the list
      inviteeList.removeAt(index);

      emit(InviteesLoaded(
        inviteeModel: InviteeModel(
          invitees: inviteeList,
          lastDoc: currentState.inviteeModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  void addInviteeBack(int index, Invitee invitee) {
    final currentState = state;
    if (currentState is InviteesLoaded) {
      final inviteeList = currentState.inviteeModel.invitees.toList();
      // remove the invitee from the list
      inviteeList.insert(index, invitee);

      emit(InviteesLoaded(
        inviteeModel: InviteeModel(
          invitees: inviteeList,
          lastDoc: currentState.inviteeModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  /// Helper methods
  bool hasMore(List<Invitee> inviteeList) {
    if (inviteeList.isEmpty) return false;
    return inviteeList.length % GlobalUtils.inviteeListLimit == 0;
  }

  List<Invitee> _mapDataToModel(List data) {
    final inviteeList = <Invitee>[];
    for (final inviteeJson in data) {
      inviteeList.add(Invitee.fromMap(inviteeJson as Map<String, dynamic>));
    }

    return inviteeList;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
