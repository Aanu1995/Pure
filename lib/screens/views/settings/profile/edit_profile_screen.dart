import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pure/screens/views/settings/widgets/items.dart';
import 'package:pure/utils/app_theme.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_extension.dart';
import '../../../../utils/validators.dart';
import '../../../widgets/snackbars.dart';
import 'widgets/profile_pic_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final PureUser user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();

  final _firstNameNode = FocusNode();
  final _locationNode = FocusNode();
  final _lastNameNode = FocusNode();
  final _aboutNode = FocusNode();

  final _decoration = InputDecoration(
    filled: true,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
  );

  final _textStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  @override
  void initState() {
    super.initState();
    initializeUserData(widget.user);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _aboutNode.dispose();
    _locationNode.dispose();
    super.dispose();
  }

  void initializeUserData(final PureUser user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _locationController.text = user.location;
    _aboutController.text = user.about!;
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
          'Edit Profile',
          style: const TextStyle(
            fontSize: 17.0,
            fontFamily: Palette.sanFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: updateProfile,
            child: Text(
              'Save',
              style: _textStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: updateProfileStateListener,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // profile widget
                  const ProfilePictureWidget(),

                  TitleHeader(
                    title: "Info",
                    fontSize: 24.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TextFormField(
                              cursorColor: primaryVariantColor,
                              controller: _firstNameController,
                              focusNode: _firstNameNode,
                              style: _textStyle,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validateInput(
                                  error: "Enter a valid name"),
                              scrollPadding:
                                  const EdgeInsets.only(bottom: 250.0),
                              decoration: _decoration.copyWith(
                                fillColor: secondaryColor,
                                hintText: 'First Name',
                                labelText: 'First Name',
                                labelStyle: TextStyle(color: secondaryVarColor),
                              ),
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_lastNameNode),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          // Last Name

                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TextFormField(
                              cursorColor: primaryVariantColor,
                              controller: _lastNameController,
                              focusNode: _lastNameNode,
                              style: _textStyle,
                              scrollPadding:
                                  const EdgeInsets.only(bottom: 250.0),
                              validator: Validators.validateInput(
                                  error: "Enter a valid name"),
                              textInputAction: TextInputAction.next,
                              decoration: _decoration.copyWith(
                                fillColor: secondaryColor,
                                hintText: 'Last Name',
                                labelText: 'Last Name',
                                labelStyle: TextStyle(color: secondaryVarColor),
                              ),
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_locationNode),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TextFormField(
                              cursorColor: primaryVariantColor,
                              controller: _locationController,
                              focusNode: _locationNode,
                              style: _textStyle,
                              scrollPadding:
                                  const EdgeInsets.only(bottom: 250.0),
                              validator: Validators.validateInput(
                                  error: "Enter a valid location"),
                              textInputAction: TextInputAction.next,
                              decoration: _decoration.copyWith(
                                fillColor: secondaryColor,
                                hintText: 'Location',
                                labelText: 'Location',
                                labelStyle: TextStyle(color: secondaryVarColor),
                              ),
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_aboutNode),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TextField(
                              cursorColor: primaryVariantColor,
                              controller: _aboutController,
                              focusNode: _aboutNode,
                              keyboardType: TextInputType.multiline,
                              maxLines: 20,
                              minLines: 2,
                              maxLength: 600,
                              scrollPadding: EdgeInsets.only(bottom: 250),
                              // buildCounter: counterText,
                              textInputAction: TextInputAction.newline,
                              style: _textStyle,
                              decoration: _decoration.copyWith(
                                fillColor: secondaryColor,
                                hintText: 'About',
                                labelText: 'About',
                                labelStyle: TextStyle(color: secondaryVarColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateProfile() {
    FocusScope.of(context).unfocus(); // hides active keyboard
    if (_formKey.currentState!.validate()) {
      final user = widget.user;
      final userModel = PureUser(
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: _firstNameController.text.trim().toSentenceCase(),
        lastName: _lastNameController.text.trim().toSentenceCase(),
        location: _locationController.text.trim(),
        photoURL: user.photoURL,
        about: _aboutController.text,
      );

      BlocProvider.of<UserProfileCubit>(context)
          .updateUserProfile(user.id, userModel.toUpdateMap());
    }
  }
}
