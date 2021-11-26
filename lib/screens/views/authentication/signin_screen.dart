import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../blocs/bloc.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/navigate.dart';
import '../../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';
import 'reset_password_screen.dart';
import 'widgets/auth_bloc_provider.dart';
import 'widgets/intro_section.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

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
                  child: const IntroSection(title: 'Sign In', fontSize: 50),
                ),
                SizedBox(height: 30.h),
                const _SignInExt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInExt extends StatefulWidget {
  const _SignInExt({Key? key}) : super(key: key);

  @override
  __SignInExtState createState() => __SignInExtState();
}

class __SignInExtState extends State<_SignInExt> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();

  bool obscureText = true;

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
    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  // update as state in Bloc Listener updates
  void authStateListener(BuildContext context, AuthUserState state) {
    if (state is AuthInProgress) {
      EasyLoading.show(status: 'Authenticating...');
    } else if (state is LoginSuccess) {
      updateUserFCMToken(state.pureUser.id); // updates fcm token
      EasyLoading.dismiss().then((value) => Navigator.pop(context, state));
    } else if (state is AuthUserFailure) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryVariantColor = Theme.of(context).colorScheme.primaryVariant;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final secondaryVarColor = Theme.of(context).colorScheme.secondaryVariant;

    return BlocListener<AuthUserCubit, AuthUserState>(
      listener: authStateListener,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailNode,
                cursorColor: primaryVariantColor,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                style: _textStyle,
                scrollPadding: const EdgeInsets.only(bottom: 250),
                decoration: _decoration.copyWith(
                  fillColor: secondaryColor,
                  hintText: 'Email Address',
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: secondaryVarColor),
                ),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordNode),
                validator: Validators.validateEmail(),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _passwordController,
                obscureText: obscureText,
                focusNode: _passwordNode,
                cursorColor: primaryVariantColor,
                style: _textStyle,
                scrollPadding: const EdgeInsets.only(bottom: 250),
                decoration: _decoration.copyWith(
                  fillColor: secondaryColor,
                  hintText: 'Password',
                  labelText: 'Password',
                  labelStyle: TextStyle(color: secondaryVarColor),
                ),
                validator: Validators.validatePassword2(),
                onFieldSubmitted: (_) => signIn(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    push(context: context, page: const ResetPasswordScreen()),
                child: Text(
                  'Forgot password?',
                  style: _textStyle.copyWith(color: primaryVariantColor),
                ),
              ),
            ),
            const SizedBox(height: 50),
            CustomButton(title: 'LOG IN', onPressed: signIn),
          ],
        ),
      ),
    );
  }

  void signIn() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      BlocProvider.of<AuthUserCubit>(context)
          .signInWithEmailAndPassword(email: email, password: password);
    }
  }
}
