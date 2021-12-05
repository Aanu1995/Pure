import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/chat_model.dart';
import '../../../../../utils/app_permission.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/navigate.dart';
import '../../../../../utils/pick_file_dialog.dart';
import '../../../photo_view_screen.dart';

class GroupBanner extends StatefulWidget {
  final ChatModel chat;
  const GroupBanner({Key? key, required this.chat}) : super(key: key);

  @override
  State<GroupBanner> createState() => _GroupBannerState();
}

class _GroupBannerState extends State<GroupBanner> {
  ImageMethods imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewGroupPhoto(),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (imageFile != null)
            Image.file(imageFile!, fit: BoxFit.cover)
          else if (widget.chat.groupImage!.isEmpty)
            Image.asset(ImageUtils.user, fit: BoxFit.cover)
          else
            Hero(
              tag: widget.chat.groupImage!,
              child: CachedNetworkImage(
                imageUrl: widget.chat.groupImage!,
                fit: BoxFit.cover,
              ),
            ),
          BlocConsumer<GroupChatCubit, GroupChatState>(
            listener: (context, state) {
              if (state is GroupChatUpdated) imageFile = null;
            },
            builder: (context, state) {
              if (state is UploadingGroupImage)
                return Center(child: CircularProgressIndicator());
              return Offstage();
            },
          ),
          Positioned(
            right: 10.0,
            bottom: 10.0,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
              onPressed: () => pickImage(),
            ),
          )
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    // hide keyboard
    FocusScope.of(context).unfocus();
    // shows a bottom sheet to select source [Camera or Gallery]
    // through which user intends to pick image
    FileOption? option = await showFileUploadBottomSheet(
      context,
      imagesOnly: true,
      showDeleteOption: false,
    );

    if (option == FileOption.gallery) {
      await _OnOptionSelected(ImageSource.gallery);
    } else if (option == FileOption.camera) {
      await _OnOptionSelected(ImageSource.camera);
    }
  }

  Future<void> _OnOptionSelected(ImageSource source) async {
    try {
      final file =
          await imageMethods.pickImage(_imagePicker, source, crop: false);
      if (file != null) {
        setState(() => imageFile = file);
        context.read<GroupChatCubit>().uploadGroupImage(widget.chat, file);
      }
    } on PlatformException catch (_) {
      if (source == ImageSource.gallery) {
        // check for photo permission
        await AppPermission.checkPhotoPermission(context);
      } else if (source == ImageSource.camera) {
        // check for camera permission
        await AppPermission.checkCameraPermission(context);
      }
    }
  }

  void viewGroupPhoto() {
    if (widget.chat.groupImage!.isNotEmpty && imageFile == null)
      push(
        context: context,
        page: ViewFullPhoto(
          tag: widget.chat.groupImage!,
          imageURL: widget.chat.groupImage!,
        ),
      );
  }
}
