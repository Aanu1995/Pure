import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../services/chat/chat_service.dart';
import '../../services/user_service.dart';

class UserPresenceProvider extends StatelessWidget {
  final String userId;
  final Widget child;
  const UserPresenceProvider(
      {Key? key, required this.userId, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) =>
          UserPresenceCubit(UserServiceImpl())..getUserPresence(userId),
      child: child,
    );
  }
}

class ProfileProvider extends StatelessWidget {
  final String userId;
  final Widget child;
  const ProfileProvider({Key? key, required this.userId, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => ProfileCubit(UserServiceImpl())..getProfile(userId),
      child: child,
    );
  }
}

class GroupMembersProvider extends StatelessWidget {
  final List<String> members;
  final Widget child;
  const GroupMembersProvider(
      {Key? key, required this.members, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) =>
          GroupCubit(ChatServiceImp())..getGroupMembersProfile(members),
      child: child,
    );
  }
}
