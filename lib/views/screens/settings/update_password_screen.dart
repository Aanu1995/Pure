import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/bloc.dart';
import '../../../utils/palette.dart';
import '../../widgets/snackbars.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _onSubmitNotifier = ValueNotifier(false);

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _currentPasswordNode = FocusNode();
  final _newPasswordNode = FocusNode();
  final _confirmNode = FocusNode();

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

  void updatePasswordStateListener(BuildContext context, AuthUserState state) {
    if (state is AuthInProgress) {
      EasyLoading.show(status: 'Updating...');
    } else if (state is UpdatePasswordSuccess) {
      EasyLoading.dismiss();
      showSuccessFlash(context, "Password updated successfully");
      Navigator.pop(context);
    } else if (state is UpdatePasswordFailed) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message, position: FlashPosition.top);
    }
  }

  @override
  void dispose() {
    _onSubmitNotifier.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordNode.dispose();
    _newPasswordNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (currentPassword.length >= 6 &&
        newPassword.length >= 6 &&
        newPassword == confirmPassword) {
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
          'Update Password',
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
                onPressed: isValidated ? changePassword : null,
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
        listener: updatePasswordStateListener,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
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
                      cursorColor: primaryVariantColor,
                      autofocus: true,
                      style: _textStyle,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration.copyWith(
                        fillColor: secondaryColor,
                        hintText: 'Current Password',
                        labelText: 'Current Password',
                        labelStyle: TextStyle(color: secondaryVarColor),
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_newPasswordNode),
                      onChanged: onChanged,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      focusNode: _newPasswordNode,
                      cursorColor: primaryVariantColor,
                      style: _textStyle,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration.copyWith(
                        fillColor: secondaryColor,
                        hintText: 'New Password',
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: secondaryVarColor),
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_confirmNode),
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Confirm Password
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmNode,
                      cursorColor: primaryVariantColor,
                      obscureText: true,
                      style: _textStyle,
                      decoration: _decoration.copyWith(
                        fillColor: secondaryColor,
                        hintText: 'Confirm Password',
                        labelText: 'Confirm Password',
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

  void changePassword() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<AuthUserCubit>(context).updatePassword(
      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );
  }
}
