import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../widgets/grouped_list/grouped_list.dart';
import 'date_separator_widget.dart';
import 'empty_widget.dart';
import 'load_more_widgets.dart';
import 'new_message_widget.dart';
import 'receipient_message_widget.dart';
import 'user_message_widget.dart';

class Messagesbody extends StatefulWidget {
  final String chatId;
  final String? firstName;
  final ValueChanged<MessageModel> onSentButtonPressed;
  final FocusNode inputFocusNode;
  const Messagesbody({
    Key? key,
    required this.chatId,
    this.firstName,
    required this.onSentButtonPressed,
    required this.inputFocusNode,
  }) : super(key: key);

  @override
  _MessagesbodyState createState() => _MessagesbodyState();
}

class _MessagesbodyState extends State<Messagesbody> {
  final _controller = ScrollController();
  double lastPos = 0.0;

  int showNewMessageAtIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateMessageOnScroll);
    _controller.addListener(_fetchOldMessagesOnScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void oldMessagesListener(BuildContext context, final MessageState state) {
    if (state is MessagesLoaded)
      context.read<MessageCubit>().updateOldMessages(state);
  }

  void newMessagesListener(BuildContext context, final MessageState state) {
    if (state is MessagesLoaded) {
      if (widget.inputFocusNode.hasFocus) {
        // Occur if user keyboard is open, new messages should be updated automatically
        _updateLatestMessage(state);
      } else {
        final minScroll = _controller.position.minScrollExtent;
        final currentScroll = _controller.offset;
        final isView = currentScroll - minScroll <= 300;

        if (isView && !_controller.position.outOfRange) {
          _updateLatestMessage(state);
        } else if (state.messagesModel.messages.length > 0) {
          showNewMessageAtIndex = (state.messagesModel.messages.length - 1);
          lastPos = showNewMessageAtIndex * 35;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewMessagesCubit, MessageState>(
      listenWhen: (prev, currrent) =>
          prev is MessageInitial && currrent is MessagesLoaded,
      listener: (context, state) {
        if (state is MessagesLoaded) {
          showNewMessageAtIndex = (state.messagesModel.messages.length - 1);
          lastPos = showNewMessageAtIndex * 35;
        }
      },
      child: Stack(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<NewMessagesCubit, MessageState>(
                listener: newMessagesListener,
              ),
              BlocListener<LoadMoreMessageCubit, MessageState>(
                listener: oldMessagesListener,
              )
            ],
            child: BlocBuilder<MessageCubit, MessageState>(
              buildWhen: (prev, current) =>
                  (prev is MessageInitial && current is MessagesLoaded) ||
                  (prev is MessagesLoaded &&
                      current is MessagesLoaded &&
                      prev.messagesModel != current.messagesModel),
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  final messages = state.messagesModel.messages;
                  if (messages.isEmpty && widget.firstName != null)
                    return EmptyMessage(
                      firstName: widget.firstName!,
                      onPressed: (String text) => sendMessage(text),
                    );
                  else {
                    return GroupedListView(
                      controller: _controller,
                      elements: messages,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      groupBy: (MessageModel element) => DateTime(
                        element.sentDate!.year,
                        element.sentDate!.month,
                        element.sentDate!.day,
                      ),
                      reverse: true,
                      groupSeparatorBuilder: (DateTime date) {
                        return GroupDateSeparator(date: date);
                      },
                      indexedItemBuilder: (context, index) {
                        if (index == messages.length) {
                          return LoadMoreMessagesWidget(
                            onTap: () => _fetchMore(tryAgain: true),
                          );
                        } else {
                          double spacing = 0.0;
                          final message = messages[index];
                          final isSelf =
                              message.isSelf(CurrentUser.currentUserId);

                          if (index > 0)
                            spacing = isSame(index, messages) ? 4.0 : 16.0;

                          return Column(
                            children: [
                              // this displays new message header to user
                              if (showNewMessageAtIndex == index)
                                Builder(builder: (context) {
                                  showNewMessageAtIndex = -1;
                                  return const NewMessageSeparator();
                                }),
                              Padding(
                                key: ValueKey(message),
                                padding: EdgeInsets.only(
                                  bottom: spacing,
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                child: isSelf
                                    ? UserMessage(
                                        key: ValueKey(message),
                                        hideNip: hideNip(index, messages),
                                        chatId: widget.chatId,
                                        message: message,
                                      )
                                    : ReceipientMessage(
                                        key: ValueKey(message),
                                        hideNip: hideNip(index, messages),
                                        message: message,
                                        isGroupMessage:
                                            widget.firstName == null,
                                      ),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  }
                }
                return Offstage();
              },
            ),
          ),
          // shows new message button
          NewMessageWidget(
            controller: _controller,
            onNewMessagePressed: () => animateToBottom(0),
          ),
        ],
      ),
    );
  }

  void animateToBottom(final double offset) {
    if (_controller.hasClients) {
      _controller.jumpTo(offset);
    }
  }

  void _updateLatestMessage(final MessagesLoaded state) {
    context.read<MessageCubit>().updateNewMessages(state);
    context.read<NewMessagesCubit>().emptyMessages();
    // animateToBottom(lastPos);
    lastPos = 0.0;
  }

  void _updateMessageOnScroll() {
    if (lastPos > 0) {
      final state = context.read<NewMessagesCubit>().state;
      if (state is MessagesLoaded && state.messagesModel.messages.isNotEmpty)
        _updateLatestMessage(state);
    }
  }

  void _fetchOldMessagesOnScroll() {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    final notOutOfRange = !_controller.position.outOfRange;

    final isInView = maxScroll - currentScroll <= 50;
    if (isInView && notOutOfRange) {
      _fetchMore();
    }
  }

  Future<void> loadAgain(final MessagesModel model) async {
    // call the provider to fetch more messages
    if (model.lastDoc != null) {
      await context
          .read<LoadMoreMessageCubit>()
          .loadMoreMessages(widget.chatId, model.lastDoc!);
    }
  }

  Future<void> _fetchMore({bool tryAgain = false}) async {
    final state = context.read<MessageCubit>().state;
    if (state is MessagesLoaded) {
      if (tryAgain) {
        loadAgain(state.messagesModel);
      } else {
        final loadMoreState = context.read<LoadMoreMessageCubit>().state;
        if (loadMoreState is! LoadingMessages &&
            state is! MessagesFailed &&
            state.hasMore) {
          loadAgain(state.messagesModel);
        }
      }
    }
  }

  bool isSame(final int index, final List<MessageModel> messages) {
    return messages[index - 1].senderId == messages[index].senderId;
  }

  bool hideNip(final int index, final List<MessageModel> messages) {
    if (messages.length >= 2 && index < (messages.length - 1)) {
      final currentMessage = messages[index];
      final nextMessage = messages[index + 1];
      if (groupDate(currentMessage.sentDate!) !=
          groupDate(nextMessage.sentDate!)) {
        return false;
      } else {
        return currentMessage.senderId == nextMessage.senderId;
      }
    }
    return false;
  }

  void sendMessage(String text) {
    final message = MessageModel.newMessage(
      text,
      CurrentUser.currentUserId,
    );
    widget.onSentButtonPressed.call(message);
  }
}
