import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_utils.dart';
import '../../../../widgets/grouped_list/grouped_list.dart';
import '../../../connections/widgets/message_widget.dart';
import 'date_separator_widget.dart';
import 'load_more_widgets.dart';
import 'message_widgets.dart';
import 'new_message_widget.dart';

class Messagesbody extends StatefulWidget {
  final String chatId;
  const Messagesbody({Key? key, required this.chatId}) : super(key: key);

  @override
  _MessagesbodyState createState() => _MessagesbodyState();
}

class _MessagesbodyState extends State<Messagesbody> {
  final _controller = ScrollController();
  double lastPos = 0.0;

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

  void realTimeMessageListener(BuildContext context, final MessageState state) {
    if (state is MessagesLoaded) {
      final hasBottomPadding = MediaQuery.of(context).viewInsets.bottom > 0;
      // Occurs when the messages list is empty and the controller has not
      // been attached to the listview builder for messages
      if (_controller.hasClients == false) {
        return _updateLatestMessage(state);
      } else if (hasBottomPadding) {
        // Occur if user keyboard is open, new messages should be autom
        _updateLatestMessage(state);
      } else {
        lastPos = _controller.position.pixels;
        final minScroll = _controller.position.minScrollExtent;
        final currentScroll = _controller.offset;
        final isView = currentScroll - minScroll <= 300;

        if (isView && !_controller.position.outOfRange) {
          _updateLatestMessage(state);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MultiBlocListener(
          listeners: [
            BlocListener<RealTimeMessageCubit, MessageState>(
              listener: realTimeMessageListener,
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
                if (messages.isEmpty)
                  return MessageDisplay(
                    fontSize: 18.0,
                    title: "No messages here yet...",
                    description: "Send a message or tap on the greetings below",
                    buttonTitle: "",
                  );
                else
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

                        return Padding(
                          key: ObjectKey(message),
                          padding: EdgeInsets.only(
                            bottom: spacing,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: isSelf
                              ? UserMessage(
                                  key: ObjectKey(message),
                                  hideNip: hideNip(index, messages),
                                  chatId: widget.chatId,
                                  message: message,
                                )
                              : ReceipientMessage(
                                  key: ObjectKey(message),
                                  hideNip: hideNip(index, messages),
                                  message: message,
                                ),
                        );
                      }
                    },
                  );
              }
              return Offstage();
            },
          ),
        ),
        // shows new message button
        NewMessageWidget(
          controller: _controller,
          onNewMessagePressed: () => animateToBottom(
            (_controller.position.pixels - lastPos),
          ),
        ),
      ],
    );
  }

  void animateToBottom(final double offset) {
    if (_controller.hasClients) {
      _controller.animateTo(
        offset,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _updateLatestMessage(final MessagesLoaded state) {
    context.read<MessageCubit>().updateNewMessages(state);
    context.read<RealTimeMessageCubit>().emptyMessages();
    lastPos = 0.0;
    animateToBottom(0.0);
  }

  void _updateMessageOnScroll() {
    if (lastPos > 0) {
      final state = context.read<RealTimeMessageCubit>().state;
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
}