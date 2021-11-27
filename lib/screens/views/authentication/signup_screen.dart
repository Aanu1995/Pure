import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../blocs/bloc.dart';
import '../../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';
import 'widgets/auth_bloc_provider.dart';
import 'widgets/intro_section.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
                  child: const IntroSection(title: 'Sign Up', fontSize: 50),
                ),
                SizedBox(height: 30.h),
                const _SignUpExt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpExt extends StatefulWidget {
  const _SignUpExt({Key? key}) : super(key: key);

  @override
  __SignUpExtState createState() => __SignUpExtState();
}

class __SignUpExtState extends State<_SignUpExt> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();
  final _confirmNode = FocusNode();

  bool obscureText = true;

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  // update as state in Bloc Listener updates
  void authStateListener(BuildContext context, AuthUserState state) {
    if (state is AuthInProgress) {
      EasyLoading.show(status: 'Creating account...');
    } else if (state is SignUpSuccess) {
      EasyLoading.dismiss();
      showSuccessFlash(context, state.message);
      Navigator.of(context).pop(true);
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
            // Email
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailNode,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                cursorColor: primaryVariantColor,
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

            // Password
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _passwordController,
                obscureText: obscureText,
                focusNode: _passwordNode,
                cursorColor: primaryVariantColor,
                style: _textStyle,
                textInputAction: TextInputAction.next,
                scrollPadding: const EdgeInsets.only(bottom: 250),
                decoration: _decoration.copyWith(
                  fillColor: secondaryColor,
                  hintText: 'Password',
                  labelText: 'Password',
                  labelStyle: TextStyle(color: secondaryVarColor),
                ),
                validator: Validators.validatePassword(),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmNode),
              ),
            ),
            const SizedBox(height: 10),
            // Confirm Password
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmNode,
                obscureText: obscureText,
                cursorColor: primaryVariantColor,
                style: _textStyle,
                scrollPadding: const EdgeInsets.only(bottom: 250),
                decoration: _decoration.copyWith(
                  fillColor: secondaryColor,
                  hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: secondaryVarColor),
                ),
                validator: (confirmPassword) => Validators.confirmPassword(
                    _passwordController.text, confirmPassword!),
                onFieldSubmitted: (_) => signUp(),
              ),
            ),
            const SizedBox(height: 50),
            CustomButton(
              width: 1.sw * 0.5,
              title: 'CREATE ACCOUNT',
              onPressed: signUp,
            ),
          ],
        ),
      ),
    );
  }

  void signUp() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      BlocProvider.of<AuthUserCubit>(context)
          .signUp(email: email, password: password);
    }
  }
}
