import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/invitation_model.dart';
import '../../../model/inviter_model.dart';
import '../../../repositories/local_storage.dart';
import '../../../services/invitation_service.dart';
import '../../../utils/exception.dart';
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
  StreamSubscription<InviterModel?>? _subscription;

  Future<void> loadInviters(String userId) async {
    List? data;

    try {
      data = await _localStorage.getData(GlobalUtils.receivedInvitationPrefKey)
          as List?;
    } catch (e) {}

    // if data is available in local storage, load from local storage first
    // and then sync the local data with remote data.
    // else load from remote database directly
    if (data != null) {
      try {
        final currentState = state;

        // load from local storage
        final inviterList = _mapDataToModel(data);

        if (currentState is ReceivedInvitationInitial) {
          emit(LoadingInviters());

          invitationService.getReceivedInvitationList(userId).then((result) {
            emit(InvitersLoaded(
              inviterModel: result,
              hasMore: hasMore(result.inviters),
            ));
          });

          // sync data
          _subscription?.cancel();
          _subscription = invitationService
              .syncInvitersLocalDatabaseWithRemote(userId)
              .listen((user) {});
        }

        emit(
          InvitersLoaded(inviterModel: InviterModel(inviters: inviterList)),
        );
      } catch (e) {
        emit(InviterLoadingFailed(ErrorMessages.generalMessage2));
      }
    } else {
      final currentState = state;
      if (currentState is ReceivedInvitationInitial) {
        // sync data
        _subscription?.cancel();
        _subscription = invitationService
            .syncInvitersLocalDatabaseWithRemote(userId)
            .listen((user) {});
      }
      // load directly from local storage
      return loadFromremoteStorage(userId);
    }
  }

  Future<void> loadFromremoteStorage(String userId) async {
    emit(LoadingInviters());

    try {
      // load directly from local storage
      final result = await invitationService.getReceivedInvitationList(userId);

      emit(InvitersLoaded(
        inviterModel: result,
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

  void updateInviters(InviterModel inviterModel, bool hasMore) {
    emit(InvitersLoaded(inviterModel: inviterModel, hasMore: hasMore));
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
          lastDocs: currentState.inviterModel.lastDocs,
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
          lastDocs: currentState.inviterModel.lastDocs,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  // This disposes the stream and initialize the cubit
  void dispose() {
    _subscription?.cancel();
    emit(ReceivedInvitationInitial());
  }

  /// Helper methods

  bool hasMore(List<Inviter> inviterList) {
    if (inviterList.isEmpty) {
      return false;
    }
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
