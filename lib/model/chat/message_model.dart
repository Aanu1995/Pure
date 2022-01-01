import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

import '../../utils/app_utils.dart';
import 'attachment_model.dart';

enum Receipt { Failed, Pending, Sent, Delivered, Read }

class MessagesModel extends Equatable {
  final List<MessageModel> messages;
  final DocumentSnapshot? lastDoc;
  final String? topMessageDate;

  const MessagesModel(
      {required this.messages, this.lastDoc, this.topMessageDate});

  @override
  List<Object?> get props => [messages, lastDoc, topMessageDate];
}

class MessageModel extends Equatable {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime? sentDate;
  final Receipt receipt;
  final List<Attachment>? attachments;
  final PreviewData? linkPreviewData;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    this.sentDate,
    this.receipt = Receipt.Pending,
    this.attachments,
    this.linkPreviewData,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    List<Attachment>? _attachments;
    PreviewData? _linkPreviewData;

    // converts json attachments to model attachments
    final attachmentsJson = data["attachments"] as List?;
    if (attachmentsJson != null) {
      _attachments = [];
      for (final attachment in attachmentsJson) {
        final result =
            Attachment.getAttachment(attachment as Map<String, dynamic>);
        if (result != null) _attachments.add(result);
      }
    }

    // converts json linkPreviewDara to model linkPreviewDara
    final _linkPreviewDataJson =
        data["link_preview_data"] as Map<String, dynamic>?;
    if (_linkPreviewDataJson != null) {
      _linkPreviewData = PreviewData.fromJson(_linkPreviewDataJson);
    }

    return MessageModel(
      messageId: data["messageId"] as String,
      senderId: data["senderId"] as String,
      text: data["text"] as String,
      sentDate: DateTime.parse(data['sentDate'] as String).toLocal(),
      receipt: getReadReceipt(data["status"] as int),
      attachments: _attachments,
      linkPreviewData: _linkPreviewData,
    );
  }

  MessageModel copyWith({Receipt? newRecept, PreviewData? linkData}) {
    return MessageModel(
      messageId: messageId,
      senderId: senderId,
      text: text,
      sentDate: sentDate,
      receipt: newRecept ?? Receipt.Failed,
      attachments: attachments,
      linkPreviewData: linkData ?? linkPreviewData,
    );
  }

  MessageModel copyWithUpdateReceipt(String lastViewDate, Receipt msgReceipt) {
    return MessageModel(
      messageId: messageId,
      senderId: senderId,
      text: text,
      sentDate: sentDate,
      receipt: lastViewDate.compareTo(sentDate!.toUtc().toIso8601String()) >= 0
          ? Receipt.Read
          : msgReceipt,
      attachments: attachments,
      linkPreviewData: linkPreviewData,
    );
  }

  MessageModel copyWithAttachments(List<Attachment> attachs) {
    return MessageModel(
      messageId: messageId,
      senderId: senderId,
      text: text,
      sentDate: sentDate,
      receipt: receipt,
      attachments: attachs,
      linkPreviewData: linkPreviewData,
    );
  }

  static MessageModel newMessage(final String text, final String senderId) {
    return MessageModel(
      messageId: generateDatabaseId(),
      senderId: senderId,
      text: text,
      sentDate: DateTime.now(),
      receipt: Receipt.Pending,
    );
  }

  static MessageModel newMessageWithAttachment(
      final String text, final String senderId, List<Attachment> attachments) {
    return MessageModel(
      messageId: generateDatabaseId(),
      senderId: senderId,
      text: text,
      sentDate: DateTime.now(),
      receipt: Receipt.Pending,
      attachments: attachments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "messageId": messageId,
      "senderId": senderId,
      "text": text,
      "sentDate": sentDate!.toUtc().toIso8601String(),
      "status": 1,
      "attachments": attachments?.map((e) => e.toMap()).toList(),
      "link_preview_data": linkPreviewData?.toJson(),
    };
  }

  bool isSelf(final String currentUserId) => senderId == currentUserId;

  String get time => DateFormat.jm().format(sentDate!);

  static Receipt getReadReceipt(final int status) {
    switch (status) {
      case 3:
        return Receipt.Read;
      case 2:
        return Receipt.Delivered;
      case 1:
        return Receipt.Sent;
      case 0:
        return Receipt.Pending;
      default:
        return Receipt.Failed;
    }
  }

  @override
  List<Object?> get props => [
        messageId,
        senderId,
        text,
        sentDate,
        receipt,
        attachments,
        linkPreviewData
      ];
}
