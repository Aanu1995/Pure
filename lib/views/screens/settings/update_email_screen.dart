import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/bloc.dart';
import '../../../model/pure_user_model.dart';
import '../../../utils/palette.dart';
import '../../../utils/validators.dart';
import '../../widgets/snackbars.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  _UpdateEmailScreenState createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _onSubmitNotifier = ValueNotifier(false);

  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();

  final _currentPasswordNode = FocusNode();
  final _newEmailNode = FocusNode();

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
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
  }

  void updateEmailStateListener(BuildContext context, AuthUserState state) {
    if (state is AuthInProgress) {
      EasyLoading.show(status: 'Updating...');
    } else if (state is UpdateEmailSuccess) {
      EasyLoading.dismiss();
      Navigator.pop(context);
    } else if (state is UpdateEmailFailed) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message, position: FlashPosition.top);
    }
  }

  @override
  void dispose() {
    _onSubmitNotifier.dispose();
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _currentPasswordNode.dispose();
    _newEmailNode.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    final currentPassword = _currentPasswordController.text.trim();

    if (currentPassword.length >= 6 &&
        Validators.validateEmail2(_newEmailController.text)) {
      _onSubmitNotifier.value = true;
    } else {
      _onSubmitNotifier.value = false;
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
          'Update Email Address',
          style: const TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _onSubmitNotifier,
            builder: (context, isValidated, _) {
              return TextButton(
                onPressed: isValidated ? updateEmail : null,
                child: Text(
                  'Save',
                  style: _textStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              );
            },
          )
        ],
      ),
      body: BlocListener<AuthUserCubit, AuthUserState>(
        listener: updateEmailStateListener,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Password
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      focusNode: _currentPasswordNode,
                      autofocus: true,
                      cursorColor: primaryVariantColor,
                      style: _textStyle,
                      textInputAction: TextInputAction.next,
                      scrollPadding: const EdgeInsets.only(bottom: 250),
                      decoration: _decoration.copyWith(
                        fillColor: secondaryColor,
                        hintText: 'Current Password',
                        labelText: 'Current Password',
                        labelStyle: TextStyle(color: secondaryVarColor),
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_newEmailNode),
                      onChanged: onChanged,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TextFormField(
                      controller: _newEmailController,
                      focusNode: _newEmailNode,
                      style: _textStyle,
                      cursorColor: primaryVariantColor,
                      keyboardType: TextInputType.emailAddress,
                      scrollPadding: const EdgeInsets.only(bottom: 250),
                      decoration: _decoration.copyWith(
                        fillColor: secondaryColor,
                        hintText: 'Email Address',
                        labelText: 'Email Address',
                        labelStyle: TextStyle(color: secondaryVarColor),
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateEmail() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<AuthUserCubit>(context).updateEmailAddress(
      CurrentUser.currentUserId,
      _currentPasswordController.text.trim(),
      _newEmailController.text.trim(),
    );
  }
}
