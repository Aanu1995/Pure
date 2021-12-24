import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bloc.dart';
import '../../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';
import 'widgets/auth_bloc_provider.dart';
import 'widgets/intro_section.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  String _instruction() {
    return 'Enter the email address you used to sign up and we’ll send you '
        'instructions to reset your password.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthBlocProvider(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20)
                .add(const EdgeInsets.only(bottom: 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: 1.sh * 0.25,
                    child: const IntroSection(title: "Forgot Password?")),
                SizedBox(height: 1.sh * 0.1),
                Text(
                  _instruction(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 30.h),
                const ResetPasswordScreenExt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreenExt extends StatefulWidget {
  const ResetPasswordScreenExt({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenExtState createState() => _ResetPasswordScreenExtState();
}

class _ResetPasswordScreenExtState extends State<ResetPasswordScreenExt> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // update as state in Bloc Listener updates
  void resetStateListener(BuildContext context, AuthUserState state) {
    if (state is AuthInProgress) {
      EasyLoading.show(status: 'Loading...');
    } else if (state is ResetPasswordSuccess) {
      EasyLoading.dismiss();
      GoRouter.of(context).pop(context);
      GoRouter.of(context).push("/resetpasswordsuccess");
    } else if (state is AuthUserFailure) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthUserCubit, AuthUserState>(
      listener: resetStateListener,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Theme.of(context).colorScheme.primaryVariant,
                style: _textStyle,
                scrollPadding: const EdgeInsets.only(bottom: 250),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  labelText: 'Email Address',
                  fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                ),
                onFieldSubmitted: (_) => resetPassword(),
                validator: Validators.validateEmail(),
              ),
            ),

            const SizedBox(height: 50),
            CustomButton(title: 'SEND', onPressed: resetPassword),
          ],
        ),
      ),
    );
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      BlocProvider.of<AuthUserCubit>(context).resetPassword(email);
    }
  }
}
