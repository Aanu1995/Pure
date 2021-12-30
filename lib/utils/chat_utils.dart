import '../model/chat/message_model.dart';
import 'app_utils.dart';

double isFromSameUser(final int index, final List<MessageModel> messages) {
  if (index > 0) {
    final isSameUser = messages[index - 1].senderId == messages[index].senderId;
    return isSameUser ? 4.0 : 16.0;
  } else
    return 0;
}

// Use to determine whether to hide the nip of a message container
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
