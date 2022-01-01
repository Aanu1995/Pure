import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../../../../../model/chat/attachment_model.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../utils/file_utils.dart';
import 'message_widgets.dart';

class DocFilePreviewWidget extends StatefulWidget {
  final MessageModel message;
  final Color color;
  final Color trailingColor;
  final bool isReceipient;
  final DocumentAttachment attachment;

  const DocFilePreviewWidget({
    Key? key,
    required this.message,
    required this.attachment,
    required this.color,
    required this.trailingColor,
    this.isReceipient = true,
  }) : super(key: key);

  @override
  _DocFilePreviewWidgetState createState() => _DocFilePreviewWidgetState();
}

class _DocFilePreviewWidgetState extends State<DocFilePreviewWidget> {
  late String filePath;
  bool fileExists = false;
  ValueNotifier<double> _downloadNotifier = ValueNotifier(-1.0);

  @override
  void initState() {
    super.initState();
    if (widget.attachment.fileURL != null) {
      checkIfFileExist();
    }
  }

  void checkIfFileExist() async {
    String appDirPath = await getFilePath();
    String fileId = widget.message.messageId;
    String fileExtension = widget.attachment.fileExtension;
    filePath = "$appDirPath/$fileId.$fileExtension";
    bool isExist = await File(filePath).exists();
    if (fileExists != isExist) {
      setState(() => fileExists = isExist);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color.withOpacity(0.8);
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, size: 30.0, color: iconColor),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      widget.attachment.name,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.attachment.fileURL != null)
                    if (!fileExists)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ValueListenableBuilder<double>(
                          valueListenable: _downloadNotifier,
                          builder: (context, progress, _) {
                            if (progress >= 0) {
                              return SizedBox(
                                height: 25.0,
                                width: 25.0,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2.5,
                                  color: iconColor,
                                ),
                              );
                            }
                            return IconButton(
                              onPressed: () => downloadFile(),
                              icon: Icon(
                                Icons.cloud_download_outlined,
                                size: 28.0,
                                color: iconColor,
                              ),
                            );
                          },
                        ),
                      )
                ],
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          TrailingDocText(
            key: ValueKey(
                "${widget.message.messageId}${widget.message.receipt}"),
            time: widget.message.time,
            receipt: widget.isReceipient ? null : widget.message.receipt,
            attachment: widget.attachment,
            color: widget.trailingColor,
          )
        ],
      ),
      onTap: () async {
        // if file path exists, it opens the file using the default app on
        // the user's device
        if (fileExists) {
          await OpenFile.open(filePath);
        }
      },
    );
  }

  void downloadFile() {
    Dio().download(widget.attachment.fileURL!, filePath,
        onReceiveProgress: (received, total) {
      if (total != -1) {
        _downloadNotifier.value = received / total;
      }
    }).then((value) {
      setState(() {
        fileExists = true;
      });
    });
  }
}
