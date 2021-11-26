import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/chat_model.dart';
import '../../../services/chat/chat_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/global_utils.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService chatService;

  ChatCubit(this.chatService) : super(ChatInitial());

  Future<void> fetchChats(String userId) async {
    emit(LoadingChats());

    try {
      final result = await chatService.getOfflineChats(userId);
      emit(ChatsLoaded(chatsModel: result));
      if (result.firstDoc != null) {
        _fetchRemoteChats(userId, result.firstDoc!);
      } else {
        _fetchRealTimeChats(userId);
      }
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  StreamSubscription<ChatsModel?>? _subscription;
  StreamSubscription<ChatsModel?>? _realTimeSubscription;

  // This is used to get recent chats to the first doc in the cache data
  Future<void> _fetchRemoteChats(
      String userId, DocumentSnapshot lastDoc) async {
    try {
      _subscription?.cancel();
      _subscription = chatService
          .getLastRemoteMessage(userId, lastDoc)
          .listen((chatsModel) {
        if (chatsModel != null) {
          // update chats to the latest in the remote server
          _syncChats(chatsModel);
          _subscription?.cancel();
          _subscription = null;
          // start listening to new chats in remote database
          _fetchRealTimeChats(userId);
        }
      });
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  Future<void> _fetchRealTimeChats(final String userId) async {
    try {
      _realTimeSubscription?.cancel();
      _realTimeSubscription =
          chatService.getRealTimeChats(userId).listen((chatsModel) {
        if (chatsModel != null) {
          _updateChats(chatsModel);
        }
      });
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

  void _syncChats(final ChatsModel newChatsModel) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      if (newChatsModel.chats.length >= GlobalUtils.LastFetchedchatsLimit) {
        return emit(ChatsLoaded(chatsModel: newChatsModel));
      } else {
        final newChats = <ChatModel>[
          ...newChatsModel.chats.toList(),
          ...currentState.chatsModel.chats.toList()
        ];
        emit(
          ChatsLoaded(
            chatsModel: ChatsModel(
              chats: newChats,
              lastDoc: currentState.chatsModel.lastDoc,
            ),
          ),
        );
      }
    }
  }

  void _updateChats(final ChatsModel newChatsModel) {
    final currentState = state;
    final newChats = newChatsModel.chats.toList();

    if (currentState is ChatsLoaded) {
      List<ChatModel> oldChats = currentState.chatsModel.chats.toList();

      final result = orderedSetForChats([...newChats, ...oldChats]);

      final lastDoc = oldChats.length > newChats.length
          ? currentState.chatsModel.lastDoc
          : newChatsModel.lastDoc;

      emit(
        ChatsLoaded(
          chatsModel: ChatsModel(chats: result, lastDoc: lastDoc),
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
    _realTimeSubscription?.cancel();
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}
