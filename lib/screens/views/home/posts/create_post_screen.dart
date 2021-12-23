import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_permission.dart';
import '../../../widgets/avatar.dart';
import 'widget/file_widget.dart';
import 'widget/post_visibility.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  final _postNotifier = ValueNotifier(false);
  final _focusNode = FocusNode();

  late PureUser? currentUser;
  int visibilityStatus = 0;

  List<File> imageFiles = [];
  File? originalVideoFile;
  File? trimmedVideoFile;

  final _style = const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    _controller.addListener(() {
      _postNotifier.value = _controller.text.trim().isNotEmpty;
    });
  }

  void getCurrentUser() {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (authState is Authenticated) currentUser = authState.user;
    // requests permission
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Future<void>.delayed(Duration(milliseconds: 500))
          .then((value) => AppPermission.checkVideoPermission(context));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        centerTitle: true,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
        child: Column(
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
                                focusNode: _focusNode,
                                autofocus: true,
                                style: _style,
                                maxLines: null,
                                toolbarOptions: ToolbarOptions(copy: true),
                                decoration: InputDecoration.collapsed(
                                  hintText: "What's happening?",
                                ),
                              ),

                              // preview images
                              if (imageFiles.isNotEmpty)
                                PostImagePreview(
                                  imageFiles: imageFiles,
                                  onImageRemoved: (file) =>
                                      setState(() => imageFiles.remove(file)),
                                ),
                              // preview video
                              if (trimmedVideoFile != null)
                                PostVideoPreview(
                                  key: ValueKey(trimmedVideoFile!.path),
                                  originalVideoFile: originalVideoFile!,
                                  trimmedVideoFile: trimmedVideoFile!,
                                  onVideoRemoved: onVideoRemoved,
                                  onVideoTrimmed: onVideoTrimmed,
                                ),
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
            PostFileIconWidget(
              imageFiles: imageFiles,
              videoFile: trimmedVideoFile,
              onImageFilesUpdated: onImagesPicked,
              onVideoFilePicked: onVideoFilePicked,
              requestFocus: () =>
                  FocusScope.of(context).requestFocus(_focusNode),
            ),
          ],
        ),
      ),
    );
  }

  void onImagesPicked(List<File> files) {
    imageFiles.addAll(files);
    imageFiles =
        imageFiles.sublist(0, imageFiles.length <= 4 ? imageFiles.length : 4);

    setState(() {});
    _postNotifier.value = true;
  }

  void onVideoFilePicked(File originalFile, File trimmedFile) {
    setState(() {
      originalVideoFile = originalFile;
      trimmedVideoFile = trimmedFile;
    });
    _postNotifier.value = true;
  }

  void onVideoRemoved() {
    setState(() {
      originalVideoFile = null;
      trimmedVideoFile = null;
    });
  }

  void onVideoTrimmed(File trimmedFile) {
    setState(() => trimmedVideoFile = trimmedFile);
  }
}
