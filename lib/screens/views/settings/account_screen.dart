import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bloc.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../utils/image_utils.dart';
import '../../../utils/navigate.dart';
import 'update_email_screen.dart';
import 'update_password_screen.dart';
import 'widgets/items.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account and Privacy")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return Column(
                  children: [
                    // Preferences
                    TitleHeader(
                      title: "Sign-in Methods",
                      child: Column(
                        children: [
                          Item(
                            title: "Change Email Address",
                            icon: ImageUtils.privacy,
                            onTap: () => pushToScreen(
                              context,
                              BlocProvider(
                                create: (_) => AuthUserCubit(
                                  AuthServiceImpl(),
                                  UserServiceImpl(),
                                ),
                                child: UpdateEmailScreen(),
                              ),
                            ),
                          ),
                          Item(
                            title: "Change Password",
                            icon: ImageUtils.privacy,
                            onTap: () => pushToScreen(
                              context,
                              BlocProvider(
                                create: (_) => AuthUserCubit(
                                  AuthServiceImpl(),
                                  UserServiceImpl(),
                                ),
                                child: UpdatePasswordScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Other
                    TitleHeader(
                      title: "Privacy",
                      child: Column(
                        children: [
                          Item(
                            title: "Who can find me?",
                            trailingText: "Everyone",
                            icon: ImageUtils.eye,
                            onTap: () {},
                          ),
                          Item(
                            title: "Who can message me?",
                            trailingText: "Friends",
                            icon: ImageUtils.message,
                            onTap: () {},
                          ),
                          Item(
                            title: "Who can call me with video?",
                            trailingText: "No one",
                            icon: ImageUtils.video,
                            onTap: () {},
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    )
                  ],
                );
              }
              return Offstage();
            },
          ),
        ),
      ),
    );
  }

  void pushToScreen(BuildContext context, Widget page) {
    push(context: context, page: page);
  }
}
