import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../blocs/search/search_username.dart';
import '../../../../blocs/user_profile/user_profile_cubit.dart';
import '../../../../blocs/user_profile/user_profile_state.dart';
import '../../../model/pure_user_model.dart';
import '../../../utils/palette.dart';
import '../../widgets/snackbars.dart';

class UpdateUsernameScreen extends StatefulWidget {
  final PureUser user;
  const UpdateUsernameScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateUsernameScreenState createState() => _UpdateUsernameScreenState();
}

class _UpdateUsernameScreenState extends State<UpdateUsernameScreen> {
  final _usernameNameController = TextEditingController();
  String newUsername = "";
  ValueNotifier<int> _availabilityNotifier = ValueNotifier(3);

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
  void dispose() {
    _availabilityNotifier.dispose();
    _usernameNameController.dispose();
    super.dispose();
  }

  void updateUsername() {
    final state = context.read<SearchBloc>().state;
    if (state is SearchSuccess &&
        state.isAvailable &&
        state.username.length >= 4) {
      final data = {"username": state.username};
      BlocProvider.of<UserProfileCubit>(context)
          .updateUserProfile(widget.user.id, data);
    }
  }

  // update as state in Bloc Listener updates
  void updateProfileStateListener(
      BuildContext context, UserProfileState state) {
    if (state is Loading) {
      EasyLoading.show(status: 'Updating...');
    } else if (state is UserProfileUpdateSuccess) {
      EasyLoading.dismiss();
      Navigator.pop(context);
    } else if (state is UserProfileUpdateFailure) {
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
          'Update username',
          style: const TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: updateUsername,
            child: Text(
              'Save',
              style: _style.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: updateProfileStateListener,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                title: "Current",
                child: Text(widget.user.username, style: _style),
              ),
              const SizedBox(height: 20.0),
              _Title(
                title: "New",
                child: ValueListenableBuilder<int>(
                  valueListenable: _availabilityNotifier,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TextFormField(
                        cursorColor: primaryVariantColor,
                        controller: _usernameNameController,
                        style: _style.copyWith(
                          color: textColor(value),
                        ),
                        textInputAction: TextInputAction.search,
                        scrollPadding: const EdgeInsets.only(bottom: 250.0),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_]'),
                          )
                        ],
                        decoration: _decoration.copyWith(
                          fillColor: secondaryColor,
                          hintText: 'Username',
                          labelText: 'Username',
                          labelStyle: TextStyle(color: secondaryVarColor),
                          suffixIcon: activeIcon(value),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            context
                                .read<SearchBloc>()
                                .add(TextChanged(text: value));
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: BlocConsumer<SearchBloc, SearchState>(
                  listener: (context, state) {
                    if (state is SearchStateEmpty)
                      _availabilityNotifier.value = 3;
                    else if (state is SearchStateLoading)
                      _availabilityNotifier.value = 2;
                    else if (state is SearchSuccess) {
                      if (state.isAvailable && state.username.length >= 4)
                        _availabilityNotifier.value = 1;
                      else
                        _availabilityNotifier.value = 0;
                    }
                  },
                  builder: (context, state) {
                    if (state is SearchSuccess) {
                      if (state.isAvailable && state.username.length >= 4) {
                        return Offstage();
                      } else {
                        return Container(
                          height: 50.0,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            "Username has already been taken",
                            style: _style.copyWith(
                              color: Colors.white,
                              fontSize: 16.0,
                              letterSpacing: 0.15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }
                    }
                    newUsername = "";
                    return Offstage();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color textColor(int value) {
    switch (value) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Theme.of(context).colorScheme.primaryVariant;
      default:
        return Theme.of(context).colorScheme.primaryVariant;
    }
  }

  Widget? activeIcon(int value) {
    switch (value) {
      case 0:
        return Icon(Icons.error_outline, color: Colors.redAccent, size: 30.0);
      case 1:
        return Icon(
          Icons.check_circle_outline,
          color: Palette.greenColor,
          size: 30.0,
        );
      case 2:
        return CupertinoActivityIndicator();
      default:
        return null;
    }
  }
}

class _Title extends StatelessWidget {
  final String title;
  final Widget child;
  const _Title({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: Palette.tintColor,
          ),
        ),
        const SizedBox(height: 6.0),
        child,
      ],
    );
  }
}
