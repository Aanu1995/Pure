import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bloc.dart';
import '../../../model/pure_user_model.dart';
import '../../../services/connection_service.dart';
import '../../../services/search_service.dart';
import '../../widgets/page_transition.dart';
import 'search/search_screen.dart';
import 'tabs/connections/connections_network.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({Key? key}) : super(key: key);

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConnectorCubit>().loadConnections(CurrentUser.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoadMoreConnectorCubit(
            connectionService:
                ConnectionServiceImpl(isPersistentEnabled: false),
          ),
        ),
        BlocProvider(
          create: (_) => OtherActionsConnectionCubit(
              ConnectionServiceImpl(isPersistentEnabled: false)),
        ),
      ],
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.maxFinite, 54.0),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CupertinoSearchTextField(
                          prefixInsets:
                              const EdgeInsetsDirectional.fromSTEB(6, 0, 8, 4),
                          placeholder: "Search",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          onTap: () => _onSearchFieldTapped(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.0,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                        ),
                        onPressed: () => shareInviteLink(),
                        child: Text(
                          "Invite Link",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
        body: ConnectionsNetwork(),
      ),
    );
  }

  void _onSearchFieldTapped() {
    Navigator.of(context).push<void>(
      PageTransition(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SearchConnBloc(SearchServiceImpl())),
          ],
          child: SearchScreen(),
        ),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  Future<void> shareInviteLink() async {
    // Coming Soon
  }
}
