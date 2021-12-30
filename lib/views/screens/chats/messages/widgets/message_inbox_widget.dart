import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pure/utils/chat_utils.dart';

import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_permission.dart';
import '../../../../../utils/palette.dart';
import '../../../../../utils/exception.dart';
import '../../../../../utils/file_utils.dart';
import '../../../../../utils/global_utils.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/pick_file_dialog.dart';
import '../../../../widgets/page_transition.dart';
import '../../../../widgets/snackbars.dart';
import 'file_picked_widget.dart';
import 'image_preview_screen.dart';

class MessageInputBox extends StatefulWidget {
  final String chatId;
  final ValueChanged<MessageModel> onSentButtonPressed;
  final FocusNode inputFocusNode;
  final bool allowUserTagging;
  const MessageInputBox({
    Key? key,
    required this.chatId,
    required this.onSentButtonPressed,
    required this.inputFocusNode,
    this.allowUserTagging = false,
  }) : super(key: key);

  @override
  _MessageInputBoxState createState() => _MessageInputBoxState();
}

class _MessageInputBoxState extends State<MessageInputBox> {
  late String currentUserId;
  final _imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();
  final _fileUtils = FileUtilsImpl();

  final _controller = TextEditingController();
  final _isEmptyNotifier = ValueNotifier<bool>(true);

  PlatformFile? _docfile;

  static const _textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  @override
  void initState() {
    super.initState();
    currentUserId = CurrentUser.currentUserId;
    _controller.addListener(() {
      _isEmptyNotifier.value = _controller.text.isEmpty;
      if (widget.allowUserTagging) getTaggedUsernames(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _isEmptyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border(
            top: BorderSide(
              color:
                  Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          child: _docfile != null
              ? FilePickedWidget(
                  file: _docfile!,
                  onCancelTap: () => setState(() => _docfile = null),
                  onSendPressed: () => sendMessageWithDocAttached(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _attachFile(context),
                      borderRadius: BorderRadius.circular(500),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: CircleAvatar(
                          radius: 16.0,
                          child: CircleAvatar(
                            radius: 15.0,
                            backgroundColor:
                                Theme.of(context).dialogBackgroundColor,
                            child: const Icon(Icons.add_outlined),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        controller: _controller,
                        focusNode: widget.inputFocusNode,
                        style: _textStyle.copyWith(
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        placeholder: "Write a message...",
                        placeholderStyle: _textStyle.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isEmptyNotifier,
                      builder: (context, state, _) {
                        if (state)
                          return InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(500),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Icon(
                                Icons.mic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryVariant,
                                size: 28.0,
                              ),
                            ),
                          );
                        else
                          return InkWell(
                            onTap: () => sendMessageOnly(),
                            borderRadius: BorderRadius.circular(500),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: CircleAvatar(
                                radius: 16.0,
                                backgroundColor: Palette.tintColor,
                                child: Icon(
                                  Icons.send,
                                  size: 20.0,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                          );
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _attachFile(BuildContext context) async {
    // closes keyboard if already open
    FocusScope.of(context).unfocus();
    // shows a dialog to select source [Camera or Gallery] through which user
    // intends to pick image
    FileOption? option = await showFileUploadBottomSheet(context);
    if (option == FileOption.gallery) {
      await _pickImage(ImageSource.gallery);
    } else if (option == FileOption.camera) {
      await _pickImage(ImageSource.camera);
    } else if (option == FileOption.document) {
      await _onDocumentFilePicked();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imageMethods.pickImage(
        _imagePicker,
        source,
        crop: false,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 50,
      );
      if (file != null) {
        await _showImagePreviewScreen(file, source);
      }
    } on PlatformException catch (_) {
      if (source == ImageSource.gallery) {
        // check for photo permission
        await AppPermission.checkPhotoPermission(context);
      } else if (source == ImageSource.camera) {
        // check for camera permission
        await AppPermission.checkCameraPermission(context);
      }
    } on MaximumUploadExceededException catch (e) {
      showFailureFlash(context, e.message!);
    }
  }

  Future<void> _onDocumentFilePicked() async {
    PlatformFile? file = await _fileUtils.pickFile();
    if (file != null) {
      // checks if the file picked exceeds the maximum upload size of 5mb
      // shows error message if maximum upload size is exceeded
      final int maxUploadSize = GlobalUtils.maxFileUploadSizeInByte;
      if (file.size < maxUploadSize) {
        setState(() => _docfile = file);
      } else {
        final standardSize =
            getStadardFileSize(GlobalUtils.maxFileUploadSizeInByte);
        final String message = "Maximum file upload size is $standardSize";
        showFailureFlash(context, message);
      }
    }
  }

  Future<void> _showImagePreviewScreen(
      File imageFile, ImageSource source) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<List<File>?>(
      PageTransition(
        child: ChatImagePreviewScreen(
          imageFile: imageFile,
          controller: _controller,
          source: source,
        ),
        type: PageTransitionType.bottomToTop,
      ),
    );

    if (result != null) sendMessageWithImage(result);
  }

  // send text message
  void sendMessageOnly() {
    if (_controller.text.trim().isNotEmpty) {
      final message = MessageModel.newMessage(_controller.text, currentUserId);
      widget.onSentButtonPressed.call(message);
      _controller.clear();
    }
  }

  // send images message
  void sendMessageWithImage(final List<File> imageFiles) async {
    final attachments = await getImageAttachments(imageFiles);
    final message = MessageModel.newMessageWithAttachment(
      _controller.text,
      currentUserId,
      attachments,
    );
    widget.onSentButtonPressed.call(message);
    _controller.clear();
  }

  // send documents message
  void sendMessageWithDocAttached() async {
    _controller.clear();
    final message = MessageModel.newMessageWithAttachment(
      _controller.text,
      currentUserId,
      getDocAttachments(_docfile!),
    );
    widget.onSentButtonPressed.call(message);
    setState(() => _docfile = null);
  }
}
