import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/chat/chat_model.dart';
import '../../../../services/chat/chat_service.dart';
import '../../../../utils/exception.dart';
import '../../../../utils/request_messages.dart';
import 'group_chat_state.dart';

class GroupChatCubit extends Cubit<GroupChatState> {
  final ChatService chatService;

  GroupChatCubit(this.chatService) : super(GroupChatInitial());

  Future<void> createGroupChat(ChatModel chat, File? image) async {
    emit(CreatingGroupChat());

    try {
      final result = await chatService.createGroupChat(chat, groupImage: image);
      emit(GroupChatCreated(chatModel: result));
    } on NetworkException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } catch (_) {
      emit(GroupChatsFailed(ErrorMessages.generalMessage2));
    }
  }
}
