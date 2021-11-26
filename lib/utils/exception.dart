import 'package:firebase_auth/firebase_auth.dart';

import 'request_messages.dart';

class CacheException implements Exception {
  CacheException({this.code, this.message, this.details});

  /// An error code.
  final int? code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  final dynamic details;
}

class ServerException implements Exception {
  ServerException({this.code, this.message, this.details});

  /// An error code.
  final int? code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  final dynamic details;
}

class NetworkException implements Exception {
  NetworkException({this.code, this.message, this.details});

  /// An error code.
  final int? code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  final dynamic details;
}

String authenticationException(FirebaseAuthException e,
    {bool isChangePassword = false}) {
  switch (e.code) {
    case 'user-not-found':
      return 'User with the email entered not found';
    case 'wrong-password':
      return isChangePassword
          ? 'The current password is incorrect'
          : 'The password is incorrect';
    case 'invalid-email':
      return 'This email does not exist in our database';
    case 'weak-password':
      return 'The password provided is too weak';
    case 'email-already-in-use':
      return 'User with this email already exist';
    case 'invalid-phone-number':
      return "Please provide a valid mobile no";
    case 'A network error (such as timeout, interrupted connection or '
        'unreachable host) has occurred.':
      return ErrorMessages.internetconnectionMessage;
    default:
      return ErrorMessages.generalMessage;
  }
}
