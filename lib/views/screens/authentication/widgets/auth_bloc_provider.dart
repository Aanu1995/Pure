import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../repositories/connection.dart';
import '../../../../repositories/local_storage.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_service.dart';

class AuthBlocProvider extends StatelessWidget {
  const AuthBlocProvider({Key? key, required this.child}) : super(key: key);
  final Widget child;

  static final connection = ConnectionRepoImpl();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthUserCubit(
        AuthServiceImpl(auth: FirebaseAuth.instance, connection: connection),
        UserServiceImpl(
          firestore: FirebaseFirestore.instance,
          localStorage: LocalStorageImpl(),
          connection: ConnectionRepoImpl(),
        ),
      ),
      child: child,
    );
  }
}
