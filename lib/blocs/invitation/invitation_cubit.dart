import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/invitation_service.dart';
import '../../utils/exception.dart';
import '../../utils/request_messages.dart';

class SendInvitationCubit extends Cubit<SendInvitationState> {
  final InvitationService invitationService;
  SendInvitationCubit(this.invitationService) : super(InvitationInitial());

  Future<void> sendInvitation(Map<String, dynamic> data) async {
    emit(SendingInvitation());

    try {
      await invitationService.sendInvitation(data);
      emit(InvitationSent(data['receiverId'] as String));
    } on NetworkException catch (e) {
      emit(InvitationSentfailure(e.message!));
    } on ServerException catch (e) {
      emit(InvitationSentfailure(e.message!));
    } catch (_) {
      emit(InvitationSentfailure(ErrorMessages.generalMessage2));
    }
  }
}

class SendInvitationState {
  const SendInvitationState();
}

class InvitationInitial extends SendInvitationState {}

class SendingInvitation extends SendInvitationState {}

class InvitationSent extends SendInvitationState {
  final String receiverId;

  const InvitationSent(this.receiverId);
}

class InvitationSentfailure extends SendInvitationState {
  final String message;

  const InvitationSentfailure(this.message);
}
