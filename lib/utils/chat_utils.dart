import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:intl/intl.dart';
import 'package:linkify/linkify.dart';

import '../model/chat/chat_model.dart';
import '../model/chat/message_model.dart';
import 'global_utils.dart';

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

// gets lastDoc for messages
DocumentSnapshot? getLastDoc(MessagesModel newMsg, MessagesModel oldMsg) {
  return oldMsg.messages.length > newMsg.messages.length
      ? oldMsg.lastDoc
      : newMsg.lastDoc;
}

String groupDate(DateTime date) {
  final filteredDate = DateTime(date.year, date.month, date.day);
  if (DateTime.now().difference(filteredDate).inDays == 0) return "Today";
  if (DateTime.now().difference(filteredDate).inDays == 1) return "Yesterday";
  if (DateTime.now().difference(filteredDate).inDays < 7)
    return DateFormat("EEEE").format(date);
  if (DateTime.now().difference(filteredDate).inDays < 365)
    return DateFormat.MMMEd().format(date);

  return DateFormat.yMMMd().format(date);
}

String chatTime(final DateTime date) {
  final filteredDate = DateTime(date.year, date.month, date.day);
  if (DateTime.now().difference(filteredDate).inDays == 0)
    return DateFormat.jm().format(date);
  if (DateTime.now().difference(filteredDate).inDays == 1) return "Yesterday";
  if (DateTime.now().difference(filteredDate).inDays < 7)
    return DateFormat("EEEE").format(date);

  return DateFormat.yMd().format(date);
}

// this method remove duplicate messages and still main order
List<MessageModel> orderedSetForMessages(final List<MessageModel> messages) {
  final result = messages.toList();
  final messageIds = Set<String>();
  result.retainWhere((x) => messageIds.add(x.messageId));
  return result.toList();
}

// this method remove duplicate chats and still main order
List<ChatModel> orderedSetForChats(final List<ChatModel> chats) {
  final result = chats.toList();
  final chatIds = Set<String>();
  result.retainWhere((x) => chatIds.add(x.chatId));
  return result.toList();
}

// this method remove duplicate Files and still main order
List<File> orderedSetForFiles(final List<File> files) {
  final result = files.toList();
  final chatIds = Set<int>();
  result.retainWhere((x) => chatIds.add(x.lengthSync()));
  return result.toList();
}

Future<PreviewData?> getLinkPreviewData(String text) async {
  final links = linkify(
    text,
    options: LinkifyOptions(humanize: false),
    linkifiers: [UrlLinkifier()],
  ).where((element) {
    final link = element.text;
    if (link.contains("http") || link.contains("https")) return true;
    return false;
  }).toList();

  if (links.isNotEmpty)
    return await getPreviewData(text).timeout(GlobalUtils.timeOutInDuration);
  else
    return null;
}

// extracts tagged usernames from text
List<String> getTaggedUsernames(String text) {
  final links = linkify(
    text,
    linkifiers: [UserTagLinkifier()],
  ).where((element) {
    final link = element.text;
    if (link.trim().startsWith("@")) return true;
    return false;
  }).toList();
  return links.map((e) => e.text).toList();
}

void replaceUserTagOnSelected(
    TextEditingController controller, String input, String selected) {
  final text = controller.text;
  final offset = (controller.selection.baseOffset - input.length);

  final newText = text.replaceRange(
    offset,
    controller.selection.baseOffset,
    selected,
  );

  controller.text = newText;
  final textSelection = TextSelection(baseOffset: offset, extentOffset: offset);
  final selectedTextLength = selected.length;

  controller.selection = textSelection.copyWith(
    baseOffset: textSelection.start + selectedTextLength,
    extentOffset: textSelection.start + selectedTextLength,
  );
}

// From the list of tags in a text, it gets the currently typed tag
// closest to the current cursor position
String? getTheCurrentTag(TextEditingController controller) {
  final userTags = getTaggedUsernames(controller.text);
  String? currentTag;
  final cursorPosition = controller.selection.baseOffset;
  for (final tag in userTags) {
    final matches = tag.allMatches(controller.text);
    for (final match in matches) {
      final pos = match.start;
      if (pos >= 0) {
        if ((pos + tag.length) == cursorPosition) {
          currentTag = tag.replaceAll("@", "");
          break;
        }
      }
    }
    if (currentTag != null) {
      break;
    }
  }
  return currentTag?.trim();
}

// checks if there are any failed messages
bool hasFailedMessages(List<MessageModel> messages) {
  final failedMessages =
      messages.where((msg) => msg.receipt == Receipt.Failed).toList();
  return failedMessages.length > 0;
}
