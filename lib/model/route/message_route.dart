import 'package:equatable/equatable.dart';
import 'package:pure/blocs/bloc.dart';
import 'package:pure/model/pure_user_model.dart';

class MessageRoute extends Equatable {
  final String chatId;
  final PureUser receipient;
  final bool hasPresenceActivated;
  final UserPresenceCubit? state;

  const MessageRoute({
    required this.chatId,
    required this.receipient,
    this.hasPresenceActivated = false,
    this.state,
  });

  @override
  List<Object?> get props => [chatId, receipient, hasPresenceActivated, state];
}
