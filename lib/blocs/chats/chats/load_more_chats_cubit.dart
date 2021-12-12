import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/utils/exception.dart';
import 'package:pure/utils/request_messages.dart';

import '../../../model/chat/chat_model.dart';
import '../../../services/chat/chat_service.dart';
import '../../../utils/global_utils.dart';
import '../../bloc.dart';

class LoadMoreChatsCubit extends Cubit<ChatState> {
  final ChatService chatService;

  LoadMoreChatsCubit(this.chatService) : super(ChatInitial());

  Future<void> loadMoreChats(String userId, DocumentSnapshot lastDoc) async {
    emit(LoadingChats());

    try {
      final result = await chatService.loadMoreChats(userId, lastDoc);

      emit(ChatsLoaded(chatsModel: result, hasMore: _hasMore(result.chats)));
    } on NetworkException catch (e) {
      emit(ChatsFailed(e.message!));
    } on ServerException catch (e) {
      emit(ChatsFailed(e.message!));
    } catch (_) {
      emit(ChatsFailed(ErrorMessages.generalMessage2));
    }
  }

  bool _hasMore(final List<ChatModel> chats) {
    if (chats.isEmpty) return false;

    return chats.length % GlobalUtils.chatsLimit == 0;
  }
}
