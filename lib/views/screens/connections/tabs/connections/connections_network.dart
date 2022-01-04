import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../services/connection_service.dart';
import '../../../../../services/invitation_service.dart';
import '../../../../../services/search_service.dart';
import '../../../../../utils/navigate.dart';
import '../../../../../utils/palette.dart';
import '../../search/search_friends_screen.dart';
import 'connectors_widget.dart';
import 'invitations/invitation_screen.dart';

class ConnectionsNetwork extends StatefulWidget {
  const ConnectionsNetwork({Key? key}) : super(key: key);

  @override
  State<ConnectionsNetwork> createState() => _ConnectionsNetworkState();
}

class _ConnectionsNetworkState extends State<ConnectionsNetwork> {
  final _service = InvitationServiceImp();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          (previous is Authenticated && current is Authenticated) &&
          (previous.user.connectionCounter != current.user.connectionCounter),
      listener: (context, state) {},
      builder: (context, state) {
        if (state is Authenticated) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                onTap: () => pushToInvitationScreen(),
                dense: true,
                title: const Text(
                  "Invitations",
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.50,
                  ),
                ),
                trailing: SizedBox(
                  width: 100.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (state.user.receivedCounter! > 0)
                        Text(
                          state.user.receivedCounter!.toString(),
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Palette.tintColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      const Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 12.0,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      "Connections (${state.user.connectionCounter})",
                      style: const TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(500),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 2.0,
                      ),
                      child: const Icon(CupertinoIcons.search),
                    ),
                    onTap: () => pushToSearchFriendScreen(),
                  ),
                ],
              ),
              Divider(
                height: 12.0,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
              const Expanded(child: const ConnectorsWidget())
            ],
          );
        }
        return const Offstage();
      },
    );
  }

  void pushToInvitationScreen() {
    push(
      context: context,
      rootNavigator: true,
      page: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ReceivedInvitationCubit(invitationService: _service),
          ),
          BlocProvider(
            create: (_) => SentInvitationCubit(invitationService: _service),
          ),
          BlocProvider(create: (_) => LoadMoreInviteeCubit(_service)),
          BlocProvider(create: (_) => RefreshInviteeCubit(_service)),
          BlocProvider(create: (_) => LoadMoreInviterCubit(_service)),
          BlocProvider(create: (_) => RefreshInviterCubit(_service)),
          BlocProvider(create: (_) => OtherActionsInvitationCubit(_service)),
          BlocProvider(create: (_) => OtherReceivedActionsCubit(_service)),
        ],
        child: const InvitationScreen(),
      ),
    );
  }

  Future<void> pushToSearchFriendScreen() async {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  OtherActionsConnectionCubit(ConnectionServiceImpl()),
            ),
            BlocProvider(create: (_) => SearchFriendBloc(SearchServiceImpl())),
          ],
          child: const SearchFriends(),
        ),
      ),
    );
  }
}
