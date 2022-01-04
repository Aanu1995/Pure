import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../repositories/connection.dart';
import '../../repositories/local_storage.dart';
import '../../services/user_service.dart';

class CustomMultiBlocProvider extends StatelessWidget {
  const CustomMultiBlocProvider({Key? key, required this.child})
      : super(key: key);
  final Widget child;

  static final _localStorage = LocalStorageImpl();
  static final _userService = UserServiceImpl(
    firestore: FirebaseFirestore.instance,
    localStorage: _localStorage,
    connection: ConnectionRepoImpl(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnBoardingCubit(LocalStorageImpl())),
        BlocProvider(
          create: (_) =>
              AuthCubit(FirebaseAuth.instance, _localStorage, _userService),
        ),
      ],
      child: child,
    );
  }
}
