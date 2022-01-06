import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../utils/chat_utils.dart';

class GroupDateSeparator extends StatelessWidget {
  final DateTime date;
  const GroupDateSeparator({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.symmetric(
            vertical: 7.0,
            horizontal: 10.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            groupDate(date),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class NewMessageSeparator extends StatelessWidget {
  const NewMessageSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.green.shade500)),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.symmetric(
            vertical: 7.0,
            horizontal: 10.0,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade800,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "New Messages",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.green.shade500)),
      ],
    );
  }
}

class NotificationMessage extends StatelessWidget {
  final MessageModel message;
  final int index;
  final List<MessageModel> messages;
  const NotificationMessage({
    Key? key,
    required this.message,
    required this.index,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: TSpace(index, messages),
        bottom: BSpace(index, messages),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 5.0),
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _getNotificationText(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _getNotificationText(BuildContext context) {
    final state = BlocProvider.of<AuthCubit>(context).state;
    if (state is Authenticated) {
      final currentUsername = state.user.getAtUsername;
      String subjectUsername = message.subjectUsername ?? "";
      String objectUsername = message.objectUsername ?? "";

      subjectUsername = getSubjectUsername(subjectUsername, currentUsername);
      objectUsername = getObjectUsername(objectUsername, currentUsername);
      return "$subjectUsername ${message.text} $objectUsername";
    }
    return "";
  }

  String getSubjectUsername(String? name, String currentUsername) {
    return name == currentUsername ? "You" : name ?? "";
  }

  String getObjectUsername(String? name, String currentUsername) {
    if (name != null) {
      List<String> names = name.split(",");
      // checks if the current user exists
      final index = names.indexOf(currentUsername);
      // if it exists, move the user to the first in the list
      if (index >= 0) {
        names.remove(0);
        names.insert(0, "You");
      }
      return names.join(", ");
    }
    return "";
  }

  double BSpace(final int index, final List<MessageModel> messages) {
    if (index > 0) {
      return messages[index - 1].isNotificationMessage ? 0.0 : 16.0;
    } else
      return 8;
  }

  double TSpace(final int index, final List<MessageModel> messages) {
    if (messages.length > index) {
      return messages[index + 1].isNotificationMessage ? 0.0 : 16.0;
    } else
      return 8;
  }
}
