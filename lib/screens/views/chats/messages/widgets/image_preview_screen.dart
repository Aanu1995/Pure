import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ChatImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  final TextEditingController controller;
  const ChatImagePreviewScreen(
      {Key? key, required this.imageFile, required this.controller})
      : super(key: key);

  static const _textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedPadding(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.1,
            ),
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.black),
              filterQuality: FilterQuality.high,
              imageProvider: FileImage(imageFile),
            ),
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(500),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 22.0,
                child: const Icon(
                  Icons.close_outlined,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 0, 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                      style: _textStyle,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      placeholder: "Add a caption...",
                      placeholderStyle: _textStyle.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                        horizontal: 10.0,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    borderRadius: BorderRadius.circular(500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.send,
                          size: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
