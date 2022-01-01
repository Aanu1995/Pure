import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/chat_model.dart';
import '../../../services/chat/chat_service.dart';
import '../../../utils/chat_utils.dart';
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
        _getAllNewChats(userId, result.firstDoc!);
      } else {
        _updateOnNewChat(userId);
      }
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  StreamSubscription<ChatsModel?>? _subscription;
  StreamSubscription<ChatsModel?>? _realTimeSubscription;

  // This is used to get recent chats to the first doc in the cache data
  Future<void> _getAllNewChats(String userId, DocumentSnapshot lastDoc) async {
    try {
      _subscription?.cancel();
      _subscription = chatService
          .getLastRemoteMessage(userId, lastDoc)
          .listen((chatsModel) {
        if (chatsModel != null) {
          // update chats to the latest in the remote server
          _updateUnreadChats(chatsModel);
          _subscription?.cancel();
          _subscription = null;
          // start listening to new chats in remote database
          _updateOnNewChat(userId);
        }
      });
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  Future<void> _updateOnNewChat(final String userId) async {
    try {
      _realTimeSubscription?.cancel();
      _realTimeSubscription =
          chatService.getRealTimeChats(userId).listen((chatsModel) {
        if (chatsModel != null) {
          _updateChatList(chatsModel);
        }
      });
    } catch (e) {
      emit(ChatsLoaded(chatsModel: ChatsModel(chats: [])));
    }
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

  // This method updates the UI when unread chats is available
  void _updateUnreadChats(final ChatsModel newChatsModel) {
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

  // This method updates the UI when new chat is available or when chat
  // last message is updated.
  void _updateChatList(final ChatsModel newChatsModel) {
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

  // used to add old chats to existing list of chat
  void addOldChats(final ChatsLoaded oldChatState) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final oldChats = oldChatState.chatsModel.chats.toList();
      final currentChats = currentState.chatsModel.chats.toList();

      final result = orderedSetForChats([...currentChats, ...oldChats]);
      final chatsModel = ChatsModel(
        chats: result,
        lastDoc: oldChatState.chatsModel.lastDoc,
      );

      emit(ChatsLoaded(chatsModel: chatsModel, hasMore: oldChatState.hasMore));
    }
  }

  // remove chat
  void removeChat(final String chatId) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final oldChats = currentState.chatsModel.chats.toList();
      oldChats.removeWhere((chat) => chat.chatId == chatId);
      emit(
        ChatsLoaded(
          chatsModel: ChatsModel(
            chats: oldChats,
            lastDoc: currentState.chatsModel.lastDoc,
          ),
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
    _realTimeSubscription?.cancel();
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _realTimeSubscription?.cancel();
    return super.close();
  }
}
