import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_permission.dart';
import '../../../../utils/app_theme.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/image_utils.dart';
import '../../../../utils/navigate.dart';
import '../../../../utils/pick_file_dialog.dart';
import '../../../widgets/snackbars.dart';
import '../messages/group_chat_message_screen.dart';
import 'friend_profile.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  ImageMethods imageMethods = ImageUtils();
  final _imagePicker = ImagePicker();

  final _groupNameController = TextEditingController();
  final _groupSubjectNotifier = ValueNotifier(false);
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _groupNameController.addListener(() {
      _groupSubjectNotifier.value = _groupNameController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupSubjectNotifier.dispose();
    super.dispose();
  }

  final _decoration = InputDecoration(
    filled: true,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
  );

  final _textStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  // update as state in Bloc Listener updates
  void createGroupChatStateListener(
      BuildContext context, GroupChatState state) {
    if (state is CreatingGroupChat) {
      EasyLoading.show(status: 'Creating...');
    } else if (state is GroupChatCreated) {
      EasyLoading.dismiss();
      Navigator.popUntil(context, (route) => route.isFirst);
      push(
        context: context,
        page: GroupChatMessageScreen(chatModel: state.chatModel),
      );
    } else if (state is GroupChatsFailed) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryVariantColor = Theme.of(context).colorScheme.primaryVariant;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final secondaryVarColor = Theme.of(context).colorScheme.secondaryVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Group',
          style: TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _groupSubjectNotifier,
            builder: (context, hasGroupShubject, _) {
              return TextButton(
                onPressed: hasGroupShubject ? () => createGroupChat() : null,
                child: const Text(
                  "Create",
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
      body: BlocListener<GroupChatCubit, GroupChatState>(
        listener: createGroupChatStateListener,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => pickImage(),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child:
                            imageFile != null ? null : Icon(Icons.camera_alt),
                        backgroundImage:
                            imageFile != null ? FileImage(imageFile!) : null,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TextFormField(
                          cursorColor: primaryVariantColor,
                          controller: _groupNameController,
                          style: _textStyle,
                          textInputAction: TextInputAction.next,
                          maxLength: 25,
                          scrollPadding: const EdgeInsets.only(bottom: 250.0),
                          decoration: _decoration.copyWith(
                            fillColor: secondaryColor,
                            hintText: 'Group Subject',
                            labelStyle: TextStyle(color: secondaryVarColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20.0),
                const AllMembers(),
              ],
            ),
          ),
        ),
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

  void createGroupChat() {
    final currentState = context.read<GroupCubit>().state;
    if (currentState is GroupMembers) {
      List<String> members = currentState.members.map((e) => e.id).toList();
      members.insert(0, CurrentUser.currentUserId);

      final chatModel = ChatModel(
        chatId: generateDatabaseId(),
        type: ChatType.Group,
        groupName: _groupNameController.text.trim(),
        creationDate: DateTime.now(),
        lastMessage: "Group created",
        groupCreatedBy: members.first,
        members: members,
        updateDate: DateTime.now(),
      );

      context.read<GroupChatCubit>().createGroupChat(chatModel, imageFile);
    }
  }
}
