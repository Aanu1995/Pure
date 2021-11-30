import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';

class ChatImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final TextEditingController controller;
  const ChatImagePreviewScreen(
      {Key? key, required this.imageFile, required this.controller})
      : super(key: key);

  @override
  State<ChatImagePreviewScreen> createState() => _ChatImagePreviewScreenState();
}

class _ChatImagePreviewScreenState extends State<ChatImagePreviewScreen> {
  List<File> imageFiles = [];
  List<Color?> colors = [];

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.05,
  );

  @override
  void initState() {
    super.initState();
    getImageColor(widget.imageFile);
    imageFiles.add(widget.imageFile);
  }

  Future<void> getImageColor(File image) async {
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      FileImage(image),
      size: Size(200, 200),
    );
    final color = generator.darkMutedColor?.color;
    colors.add(color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedPadding(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.1,
            ),
            child: PhotoView(
              backgroundDecoration: BoxDecoration(
                color: const Color(0xFF242424),
              ),
              filterQuality: FilterQuality.high,
              imageProvider: FileImage(imageFiles.last),
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
                      controller: widget.controller,
                      style: _textStyle.copyWith(
                        color: Theme.of(context).colorScheme.primaryVariant,
                      ),
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
                    onTap: () {
                      final data = {"files": imageFiles, "colors": colors};
                      Navigator.of(context).pop(data);
                    },
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
