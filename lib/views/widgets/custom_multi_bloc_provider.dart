import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../repositories/connection.dart';
import '../../repositories/local_storage.dart';
import '../../services/chat/chat_service.dart';
import '../../services/connection_service.dart';
import '../../services/invitation_service.dart';
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
        BlocProvider(
          create: (_) => ConnectorCubit(
            connectionService: ConnectionServiceImpl(),
          ),
        ),
        BlocProvider(
          create: (_) => ReceivedInvitationCubit(
            invitationService: InvitationServiceImp(),
          ),
        ),
        BlocProvider(
          create: (_) => SentInvitationCubit(
            invitationService: InvitationServiceImp(),
          ),
        ),
        BlocProvider(create: (_) => ChatCubit(ChatServiceImp())),
        BlocProvider(create: (_) => UnReadChatCubit(ChatServiceImp())),
      ],
      child: child,
    );
  }
}
