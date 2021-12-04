import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';

class NewMessageWidget extends StatelessWidget {
  final ScrollController controller;
  final void Function()? onNewMessagePressed;
  const NewMessageWidget(
      {Key? key, required this.controller, required this.onNewMessagePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewMessagesCubit, MessageState>(
      buildWhen: (prev, current) => current is MessagesLoaded,
      builder: (context, state) {
        if (messagesNotEmpty(state) && isOutOfMinScroll)
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: MaterialButton(
                shape: StadiumBorder(),
                color: Colors.red,
                onPressed: this.onNewMessagePressed,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.south, size: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("New Message"),
                    ),
                  ],
                ),
              ),
            ),
          );

        return Offstage();
      },
    );
  }

  bool messagesNotEmpty(MessageState state) {
    return (controller.hasClients &&
        state is MessagesLoaded &&
        state.messagesModel.messages.isNotEmpty);
  }

  bool get isOutOfMinScroll {
    final minScroll = controller.position.minScrollExtent;
    final currentScroll = controller.offset;
    final isNotView = currentScroll - minScroll >= 300;
    return (isNotView && !controller.position.outOfRange);
  }
}
