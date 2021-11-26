import 'package:pure/utils/global_utils.dart';
import 'package:email_validator/email_validator.dart';

class Validators {
  static String? Function(String?) validateInput({String? error}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return error ?? 'Field is required';
      }
      return null;
    };
  }

  static String? Function(String?) validatePassword() {
    return (String? value) {
      const invalidLength = 5;
      if (value == null || value.length <= invalidLength) {
        return 'Password must be at least 6 characters long';
      }
      return null;
    };
  }

  static String? Function(String?) validatePassword2() {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      return null;
    };
  }

  static String? Function(String?) validateEmail() {
    return (String? value) {
      if (!EmailValidator.validate(value!)) {
        return 'Please enter a valid email address';
      }
      return null;
    };
  }

  static bool validateEmail2(String value) {
    return EmailValidator.validate(value);
  }

  static String? Function(String?) validatePhone() {
    return (String? value) {
      final RegExp regExp = new RegExp(GlobalUtils.phoneRegExp);
      if (!regExp.hasMatch(value!)) {
        return 'Not a valid phone no';
      }
      return null;
    };
  }

  // checks if the current password is the same with the confirm password
  static String? confirmPassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // slip or mooring number validator
  static String? Function(String?) validateSlipOrMooring() {
    return (String? value) {
      final RegExp regExp = RegExp(r'\d');
      if (!regExp.hasMatch(value!)) {
        return 'Enter a valid slip or mooring number';
      }
      return null;
    };
  }
}
