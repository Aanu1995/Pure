import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitation_model.dart';
import '../../../model/invitee_model.dart';
import '../../../repositories/local_storage.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/exception.dart';
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
  StreamSubscription<InviteeModel?>? _subscription;

  Future<void> loadInvitees(String userId) async {
    List? data;

    try {
      data = await _localStorage.getData(GlobalUtils.sentInvitationPrefKey)
          as List?;
    } catch (e) {}

    // if data is available in local storage, load from local storage first
    // and then sync the local data with remote data.
    // else load from remote database directly
    if (data != null) {
      try {
        final currentState = state;

        // load from local storage
        final inviteeList = _mapDataToModel(data);

        if (currentState is SentInvitationInitial) {
          emit(LoadingInvitees());

          invitationService.getSentInvitationList(userId).then((result) {
            emit(InviteesLoaded(
              inviteeModel: result,
              hasMore: hasMore(result.invitees),
            ));
          });

          // sync data
          _subscription?.cancel();
          _subscription = invitationService
              .syncInviteesLocalDatabaseWithRemote(userId)
              .listen((user) {});
        }
        emit(
          InviteesLoaded(inviteeModel: InviteeModel(invitees: inviteeList)),
        );
      } catch (e) {
        emit(InviteeLoadingFailed(ErrorMessages.generalMessage2));
      }
    } else {
      final currentState = state;
      if (currentState is SentInvitationInitial) {
        // sync data
        _subscription?.cancel();
        _subscription = invitationService
            .syncInviteesLocalDatabaseWithRemote(userId)
            .listen((user) {});
      }
      // load directly from local storage
      return loadFromremoteStorage(userId);
    }
  }

  Future<void> loadFromremoteStorage(String userId) async {
    emit(LoadingInvitees());

    try {
      // load directly from local storage
      final result = await invitationService.getSentInvitationList(userId);

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

  void updateInvitees(InviteeModel inviteeModel, bool hasMore) {
    emit(InviteesLoaded(inviteeModel: inviteeModel, hasMore: hasMore));
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
          lastDocs: currentState.inviteeModel.lastDocs,
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
          lastDocs: currentState.inviteeModel.lastDocs,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  // This disposes the stream and initialize the cubit
  void dispose() {
    _subscription?.cancel();
    emit(SentInvitationInitial());
  }

  /// Helper methods

  bool hasMore(List<Invitee> inviteeList) {
    if (inviteeList.isEmpty) {
      return false;
    }
    return inviteeList.length % GlobalUtils.inviteeListLimit == 0;
  }

  List<Invitee> _mapDataToModel(List data) {
    final inviteeList = <Invitee>[];
    for (final inviteeJson in data) {
      inviteeList.add(Invitee.fromMap(inviteeJson as Map<String, dynamic>));
    }

    return inviteeList;
  }
}
