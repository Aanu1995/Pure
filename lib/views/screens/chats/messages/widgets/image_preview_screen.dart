import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/chat_utils.dart';
import '../../../../../utils/exception.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/palette.dart';
import '../../../../widgets/snackbars.dart';
import 'tagged_user_sheet.dart';

class ChatImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final TextEditingController controller;
  final ImageSource source;
  final ValueNotifier<String?>? userTaggingNotifier;
  const ChatImagePreviewScreen({
    Key? key,
    required this.imageFile,
    required this.controller,
    required this.source,
    this.userTaggingNotifier,
  }) : super(key: key);

  @override
  State<ChatImagePreviewScreen> createState() => _ChatImagePreviewScreenState();
}

class _ChatImagePreviewScreenState extends State<ChatImagePreviewScreen> {
  final _imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();
  List<File> imageFiles = [];

  PageController _controller = PageController();
  ScrollController _scrollController = ScrollController();

  int currentIndex = 0;

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.05,
  );

  @override
  void initState() {
    super.initState();
    imageFiles.add(widget.imageFile);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void deleteImage() {
    setState(() {
      imageFiles.removeAt(currentIndex);
      currentIndex =
          imageFiles.length <= currentIndex ? currentIndex -= 1 : currentIndex;
    });
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
            child: PageView.builder(
              controller: _controller,
              itemCount: imageFiles.length,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) => Image.file(imageFiles[index]),
            ),
          ),
          // Back Button
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
          // Delete Button
          if (imageFiles.length > 1)
            Positioned(
              top: 50.0,
              left: 1.sw * 0.5,
              child: IconButton(
                onPressed: () => deleteImage(),
                icon: Icon(
                  CupertinoIcons.delete,
                  color: Colors.grey.shade200,
                  size: 30,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: widget.userTaggingNotifier == null
                      ? Offstage()
                      : TaggedUserSheet(
                          controller: widget.controller,
                          userTaggingNotifier: widget.userTaggingNotifier!,
                        ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _pickImage(),
                      borderRadius: BorderRadius.circular(500),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20.0,
                          child: CircleAvatar(
                            radius: 19.0,
                            backgroundColor:
                                Theme.of(context).dialogBackgroundColor,
                            child: const Icon(Icons.add_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
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
                      onTap: () => Navigator.of(context).pop(imageFiles),
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
                if (imageFiles.length > 1)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 100.0,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageFiles.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 2.0,
                              ),
                              child: InkWell(
                                child: Container(
                                  width: 85.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: index == currentIndex
                                          ? Palette.tintColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    imageFiles[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                onTap: () {
                                  _controller.jumpToPage(index);
                                  currentIndex = index;
                                },
                              ),
                            );
                          }),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      if (widget.source == ImageSource.camera) {
        final file = await _imageMethods.pickImage(
          _imagePicker,
          widget.source,
          crop: false,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 50,
        );
        if (file != null) {
          imageFiles.add(file);
          currentIndex = imageFiles.length - 1;
          _controller.jumpToPage(currentIndex);
          setState(() {});
        }
      } else {
        final files =
            await _imageMethods.pickMultiImage(_imagePicker, imageQuality: 50);
        if (files != null) {
          imageFiles.addAll(files);
          imageFiles = orderedSetForFiles(imageFiles);

          setState(() => currentIndex = (imageFiles.length) - 1);
          Future<void>.delayed(Duration(milliseconds: 500)).then(
            (value) => _controller.jumpToPage(currentIndex),
          );
        }
      }
    } on MaximumUploadExceededException catch (e) {
      showFailureFlash(context, e.message!);
    }
  }
}
