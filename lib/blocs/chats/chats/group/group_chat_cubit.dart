import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/model/chat/message_model.dart';

import '../../../../model/chat/chat_model.dart';
import '../../../../services/chat/chat_service.dart';
import '../../../../utils/exception.dart';
import '../../../../utils/request_messages.dart';
import 'group_chat_state.dart';

class GroupChatCubit extends Cubit<GroupChatState> {
  final ChatService chatService;

  GroupChatCubit(this.chatService) : super(GroupChatInitial());

  Future<void> createGroupChat(
      ChatModel chat, MessageModel message, File? image) async {
    emit(CreatingGroupChat());

    try {
      final result =
          await chatService.createGroupChat(chat, message, groupImage: image);
      emit(GroupChatCreated(chatModel: result));
    } on NetworkException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } catch (_) {
      emit(GroupChatsFailed(ErrorMessages.generalMessage2));
    }
  }

  Future<void> updateGroupSubject(
      final ChatModel chat, String subject, MessageModel message) async {
    emit(UpdatingGroupChat());

    try {
      final data = ChatModel.toSubjectMap(subject);
      await chatService.updateGroupChat(chat.chatId, data, message);

      emit(GroupChatUpdated(chatModel: chat.copyWith(subject: subject)));
    } on NetworkException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } catch (_) {
      emit(GroupChatsFailed(ErrorMessages.generalMessage2));
    }
  }

  Future<void> updateGroupDesc(
      final ChatModel chat, String desc, MessageModel message) async {
    emit(UpdatingGroupChat());

    try {
      final data = ChatModel.toDescriptionMap(desc);
      await chatService.updateGroupChat(chat.chatId, data, message);

      emit(GroupChatUpdated(chatModel: chat.copyWith(desc: desc)));
    } on NetworkException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } catch (_) {
      emit(GroupChatsFailed(ErrorMessages.generalMessage2));
    }
  }

  Future<void> uploadGroupImage(
      final ChatModel chat, File imagefile, MessageModel message) async {
    emit(UploadingGroupImage());

    try {
      final imageURL =
          await chatService.updateGroupImage(chat.chatId, imagefile, message);
      emit(GroupChatUpdated(chatModel: chat.copyWith(image: imageURL)));
    } on NetworkException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(GroupChatsFailed(e.message!));
    } catch (_) {
      emit(GroupChatsFailed(ErrorMessages.generalMessage2));
    }
  }
}
