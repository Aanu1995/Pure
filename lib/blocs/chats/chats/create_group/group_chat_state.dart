import 'package:equatable/equatable.dart';

import '../../../../model/chat/chat_model.dart';

class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class CreatingGroupChat extends GroupChatState {}

class GroupChatCreated extends GroupChatState {
  final ChatModel chatModel;

  const GroupChatCreated({required this.chatModel});

  @override
  List<Object?> get props => [chatModel];
}

class GroupChatsFailed extends GroupChatState {
  final String message;

  const GroupChatsFailed(this.message);
}
