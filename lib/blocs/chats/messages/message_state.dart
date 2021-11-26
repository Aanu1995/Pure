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
  final String? topMessageId;
  final Map<String, dynamic>? messageIds;
  final bool hasMore;
  // if true it means the app is connected to remote messages and messages
  // sent by receipient are shown in the app as immediately.
  // if false, it means messages sent by receipient are not received
  final bool isListening;

  const MessagesLoaded({
    required this.messagesModel,
    this.topMessageId,
    this.messageIds,
    this.hasMore = true,
    this.isListening = true,
  });

  @override
  List<Object?> get props => [messagesModel, isListening];
}

class MessagesFailed extends MessageState {
  final String message;

  const MessagesFailed(this.message);
}
