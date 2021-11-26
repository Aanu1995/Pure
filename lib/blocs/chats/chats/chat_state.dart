import 'package:equatable/equatable.dart';

import '../../../model/chat/chat_model.dart';

class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class LoadingChats extends ChatState {}

class ChatsLoaded extends ChatState {
  final ChatsModel chatsModel;
  final bool hasMore;

  const ChatsLoaded({
    required this.chatsModel,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [chatsModel];
}

class ChatsFailed extends ChatState {
  final String message;

  const ChatsFailed(this.message);
}
