import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_permission.dart';
import '../../../../utils/image_utils.dart';
import '../../../widgets/avatar.dart';
import 'widget/post_visibility.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();
  late PureUser? currentUser;
  int visibilityStatus = 0;
  final _controller = TextEditingController();
  final _postNotifier = ValueNotifier(false);
  List<File> imageFiles = [];
  File? videoFile;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _controller.addListener(() {
      _postNotifier.value = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getCurrentUser() {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }
  }

  final _style = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
            ),
          ),
        ),
        title: const Text(
          'Start post',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _postNotifier,
            builder: (context, state, _) {
              return TextButton(
                onPressed: state ? () {} : null,
                child: Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentUser != null)
                      Avartar2(imageURL: currentUser!.photoURL, size: 20.0),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller,
                              autofocus: true,
                              style: _style,
                              maxLines: null,
                              toolbarOptions: ToolbarOptions(copy: true),
                              decoration: InputDecoration.collapsed(
                                hintText: "What's happening?",
                              ),
                            ),

                            // show images
                            SizedBox(
                              width: 1.sw,
                              height: 1.sw * 0.8,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: imageFiles.length,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                itemBuilder: (context, index) {
                                  final file = imageFiles[index];
                                  if (imageFiles.length == 1)
                                    return Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    );
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // show videos
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          PostVisibility(
            visibilityStatus: visibilityStatus,
            onPostVisibilityChanged: (status) => visibilityStatus = status,
          ),
          Divider(height: 0.0),
          Row(
            children: [
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: (videoFile == null && imageFiles.length <= 4)
                    ? () {}
                    : null,
                icon: Icon(FontAwesomeIcons.camera),
              ),
              IconButton(
                onPressed:
                    (videoFile == null && imageFiles.isEmpty) ? () {} : null,
                icon: Icon(FontAwesomeIcons.video),
              ),
              IconButton(
                onPressed: (videoFile == null && imageFiles.length <= 4)
                    ? () => addImagesFromGallery()
                    : null,
                icon: Icon(Icons.photo),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> addImagesFromGallery() async {
    try {
      final files = await _imageMethods.pickMultiImage(
        _imagePicker,
        imageQuality: 50,
      );
      if (files != null) {
        imageFiles.addAll(files);
        imageFiles = imageFiles.sublist(
            0, imageFiles.length <= 4 ? imageFiles.length : 4);
        setState(() {});
      }
    } on PlatformException catch (_) {
      await AppPermission.checkPhotoPermission(context);
    }
  }
}
