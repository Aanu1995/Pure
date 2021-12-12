import 'package:equatable/equatable.dart';

import '../../../model/chat/message_model.dart';

class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class LoadingMessages extends MessageState {}

class MessagesLoaded extends MessageState {
  final MessagesModel messagesModel;
  final bool hasMore;

  const MessagesLoaded({required this.messagesModel, this.hasMore = true});

  @override
  List<Object?> get props => [messagesModel];
}

class MessagesFailed extends MessageState {
  final String message;

  const MessagesFailed(this.message);
}
