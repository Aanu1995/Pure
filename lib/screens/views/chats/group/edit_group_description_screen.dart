import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../utils/app_theme.dart';
import '../../../widgets/snackbars.dart';

class EditGroupDescription extends StatefulWidget {
  final ChatModel chat;
  const EditGroupDescription({Key? key, required this.chat}) : super(key: key);

  @override
  _EditGroupDescriptionState createState() => _EditGroupDescriptionState();
}

class _EditGroupDescriptionState extends State<EditGroupDescription> {
  final _descController = TextEditingController();

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
    _descController.text = widget.chat.groupDescription!;
  }

  @override
  void dispose() {
    _descController.dispose();
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
          'Description',
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
              controller: _descController,
              style: _style,
              maxLines: 20,
              minLines: 5,
              textInputAction: TextInputAction.next,
              scrollPadding: const EdgeInsets.only(bottom: 250.0),
              decoration: _decoration.copyWith(
                fillColor: secondaryColor,
                hintText: "Add group description",
                labelStyle: TextStyle(color: secondaryVarColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void save() {
    if (_descController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      context
          .read<GroupChatCubit>()
          .updateGroupDesc(widget.chat, _descController.text);
    }
  }
}
