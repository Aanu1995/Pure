import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/chat/message_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/palette.dart';
import '../../../widgets/snackbars.dart';

class EditGroupSubject extends StatefulWidget {
  final ChatModel chat;
  const EditGroupSubject({Key? key, required this.chat}) : super(key: key);

  @override
  _EditGroupSubjectState createState() => _EditGroupSubjectState();
}

class _EditGroupSubjectState extends State<EditGroupSubject> {
  final _nameController = TextEditingController();
  late PureUser currentUser;

  final _style = const TextStyle(
    fontSize: 17.0,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
  );

  final _decoration = InputDecoration(
    filled: true,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
  );

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.chat.groupName!;
    getCurrentUser();
  }

  void getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void groupChatUpdateListener(BuildContext context, GroupChatState state) {
    if (state is UpdatingGroupChat) {
      EasyLoading.show(status: 'Updating...');
    } else if (state is GroupChatUpdated) {
      EasyLoading.dismiss();
      Navigator.pop(context);
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
        elevation: 1.0,
        title: const Text(
          'Subject',
          style: const TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => save(),
            child: Text(
              'Save',
              style: _style.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocListener<GroupChatCubit, GroupChatState>(
        listener: groupChatUpdateListener,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TextFormField(
              cursorColor: primaryVariantColor,
              autofocus: true,
              controller: _nameController,
              style: _style,
              textInputAction: TextInputAction.next,
              scrollPadding: const EdgeInsets.only(bottom: 250.0),
              maxLength: 25,
              decoration: _decoration.copyWith(
                fillColor: secondaryColor,
                hintText: widget.chat.groupName!,
                labelStyle: TextStyle(color: secondaryVarColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void save() {
    if (_nameController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      final subject = _nameController.text.trim();
      final message = MessageModel.notifyMessage(
        'changed the subject to "$subject"',
        currentUser.id,
        currentUser.getAtUsername,
      );
      context
          .read<GroupChatCubit>()
          .updateGroupSubject(widget.chat, subject, message);
    }
  }
}
