import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../utils/app_permission.dart';
import '../../../../../utils/palette.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/pick_file_dialog.dart';
import '../../../../widgets/snackbars.dart';

class ProfilePictureWidget extends StatefulWidget {
  const ProfilePictureWidget({Key? key}) : super(key: key);

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  ImageMethods imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();

  File? _imageFile;
  bool _isUploadingImage = false;

  // update as state in Bloc Listener updates
  void updateProfileStateListener(
      BuildContext context, UserProfileState state) {
    if (state is ImageUploading) {
      setState(() => _isUploadingImage = true);
    } else if (state is ProfileImageUpdateSuccess) {
      _imageFile = null;
      setState(() => _isUploadingImage = false);
    } else if (state is ProfileImageUpdateFailure) {
      setState(() => _isUploadingImage = false);
      showFailureFlash(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: BlocListener<UserProfileCubit, UserProfileState>(
          listener: updateProfileStateListener,
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (prev, current) => current is Authenticated,
            builder: (context, state) {
              if (state is Authenticated) {
                final userId = state.user.id;
                final imageURL = state.user.photoURL;
                if (_imageFile == null && imageURL.isEmpty) {
                  return _NoImageView(
                    onTap: () => pickImage(userId, imageURL.isNotEmpty),
                  );
                } else {
                  return _ImageView(
                    onTap: () => pickImage(userId, imageURL.isNotEmpty),
                    imageFile: _imageFile,
                    imageURL: imageURL,
                    isUploading: _isUploadingImage,
                  );
                }
              }
              return const Offstage();
            },
          ),
        ),
      ),
    );
  }

  Future<void> pickImage(String userId, bool showDelete) async {
    // hide keyboard
    FocusScope.of(context).unfocus();
    // shows a bottom sheet to select source [Camera or Gallery]
    // through which user intends to pick image
    FileOption? option = await showFileUploadBottomSheet(
      context,
      imagesOnly: true,
      showDeleteOption: showDelete,
    );

    if (option == FileOption.gallery) {
      await _OnOptionSelected(userId, ImageSource.gallery);
    } else if (option == FileOption.camera) {
      await _OnOptionSelected(userId, ImageSource.camera);
    } else if (option == FileOption.delete) {
      await BlocProvider.of<UserProfileCubit>(context)
          .deleteProfileImage(userId);
    }
  }

  Future<void> _OnOptionSelected(String userId, ImageSource source) async {
    try {
      final file = await imageMethods.pickImage(_imagePicker, source);
      if (file != null) {
        _imageFile = file;
        BlocProvider.of<UserProfileCubit>(context)
            .updateProfileImage(userId, file);
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
}

class _NoImageView extends StatelessWidget {
  const _NoImageView({Key? key, required this.onTap}) : super(key: key);
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(500),
      child: Container(
        height: 96.0,
        width: 96.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondaryVariant,
          ),
        ),
        child: const Icon(
          Icons.add_a_photo,
          color: Palette.greenColor,
          size: 30.0,
        ),
      ),
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView(
      {Key? key,
      required this.onTap,
      this.imageFile,
      required this.imageURL,
      this.isUploading = false})
      : super(key: key);
  final Function()? onTap;
  final File? imageFile;
  final String imageURL;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(500),
      child: SizedBox(
        height: 100.0,
        width: 100.0,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              foregroundImage: imageFile != null
                  ? FileImage(imageFile!) as ImageProvider
                  : CachedNetworkImageProvider(imageURL),
            ),
            if (isUploading)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: const Center(
                  child: SizedBox(
                    height: 26.0,
                    width: 26.0,
                    child: CircularProgressIndicator(strokeWidth: 3.0),
                  ),
                ),
              )
            else
              Positioned(
                right: 2.0,
                bottom: 2.0,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: Palette.greenColor,
                  child: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primaryVariant,
                    size: 17.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
