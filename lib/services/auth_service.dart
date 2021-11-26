import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../repositories/connection.dart';
import '../utils/exception.dart';
import '../utils/request_messages.dart';

abstract class AuthService {
  Future<User> createAccount(String email, String password);
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> changeUserEmailAddress(String currentPassword, String newEmail);
  Future<void> changeUserPassword(String currentPass, String newPass);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class AuthServiceImpl implements AuthService {
  final FirebaseAuth? auth;
  final ConnectionRepo? connection;

  AuthServiceImpl({this.auth, this.connection}) {
    _auth = auth ?? FirebaseAuth.instance;
    _connection = connection ?? ConnectionRepoImpl();
  }

  late ConnectionRepo _connection;
  late FirebaseAuth _auth;

  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly'
    ],
  );

  // call this method to sign in with email and password
  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        return user;
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // call this method to create account
  @override
  Future<User> createAccount(String email, String password) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        return user;
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // call this method to reset the user password
  @override
  Future<void> resetPassword(String email) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // call this method to update the user email address
  @override
  Future<void> changeUserEmailAddress(
      String currentPassword, String newEmail) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      final user = _auth.currentUser!;
      await user.reload();
      final credential = await reAuthenticateUser(user, currentPassword);
      if (credential.user != null) {
        await user.updateEmail(newEmail);
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // handles authentication for Google SignIn
  @override
  Future<User> signInWithGoogle() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          return user;
        } else {
          throw ServerException(message: ErrorMessages.generalMessage);
        }
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // handles authentication for Apple SignIn
  @override
  Future<User> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final AuthCredential appleCredential =
          OAuthProvider('apple.com').credential(
        accessToken: appleIdCredential.authorizationCode,
        idToken: appleIdCredential.identityToken,
      );

      final userCredential = await _auth.signInWithCredential(appleCredential);

      final user = userCredential.user;
      if (user != null) {
        return user;
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // call this method to update the user password
  @override
  Future<void> changeUserPassword(String currentPass, String newPass) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      final user = _auth.currentUser!;
      await user.reload();
      final credential = await reAuthenticateUser(user, currentPass);
      if (credential.user != null) {
        await credential.user!.updatePassword(newPass);
      } else {
        throw ServerException(message: ErrorMessages.generalMessage);
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: authenticationException(e));
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // helper method
  Future<UserCredential> reAuthenticateUser(User user, String currentPassword) {
    return user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      ),
    );
  }
}
