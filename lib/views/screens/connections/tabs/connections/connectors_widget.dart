import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../services/search_service.dart';
import '../../../../widgets/failure_widget.dart';
import '../../../../widgets/message_widget.dart';
import '../../../../widgets/page_transition.dart';
import '../../../../widgets/progress_indicator.dart';
import '../../../../widgets/snackbars.dart';
import '../../search/search_screen.dart';
import 'connectors_list.dart';

class ConnectorsWidget extends StatefulWidget {
  const ConnectorsWidget({Key? key}) : super(key: key);

  @override
  _ConnectorsWidgetState createState() => _ConnectorsWidgetState();
}

class _ConnectorsWidgetState extends State<ConnectorsWidget> {
  ScrollController _controller = ScrollController();
  late String currentuserId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    currentuserId = CurrentUser.currentUserId;
    refreshData(); // refreshes data to be in sync with remote data
  }

  ///  Listeners
  void loadMoreListener(BuildContext context, ConnectorState state) {
    if (state is ConnectionsLoaded) {
      context
          .read<ConnectorCubit>()
          .updateOldConnection(state.connectionModel, state.hasMore);
    }
  }

  void refreshListener(BuildContext context, ConnectorState state) {
    if (state is ConnectionsLoaded) {
      context.read<ConnectorCubit>().updateNewConnection(state.connectionModel);
    }
  }

  void otherActionListener(BuildContext context, ConnectorState state) {
    if (state is RemovingConnector) {
      context.read<ConnectorCubit>().delete(state.index);
    } else if (state is ConnectorRemoved) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user.copyWith(
          isRemovedConnection: true,
          identifier: state.connectorId,
        );
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
    } else if (state is ConnectorRemovalFailed) {
      showFailureFlash(
        context,
        "Failed to remove connection",
        backgroundColor: Color(0xFF04192F),
        position: FlashPosition.top,
      );
      context
          .read<ConnectorCubit>()
          .addConnectionBack(state.index, state.connector);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoadMoreConnectorCubit, ConnectorState>(
          listener: loadMoreListener,
        ),
        BlocListener<RefreshConnectionsCubit, ConnectorState>(
          listener: refreshListener,
        ),
        BlocListener<OtherActionsConnectionCubit, ConnectorState>(
          listener: otherActionListener,
        )
      ],
      child: Column(
        children: [
          // shows failure widget when refreshing invitee list failed
          BlocBuilder<RefreshConnectionsCubit, ConnectorState>(
            builder: (context, state) {
              if (state is RefreshingConnectors) {
                return RefreshLoadingWidget();
              } else if (state is ConnectorsRefreshFailed) {
                return RefreshFailureWidget(onTap: () => refreshData());
              }
              return const Offstage();
            },
          ),
          Expanded(
            child: BlocBuilder<ConnectorCubit, ConnectorState>(
              builder: (context, state) {
                if (state is ConnectionsLoaded) {
                  final connectorList = state.connectionModel.connectors;
                  if (connectorList.isEmpty)
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: 1.sh * 0.15),
                        child: MessageDisplay(
                          fontSize: 18.0,
                          title: "You don't have any connections yet",
                          description:
                              "You can search other connections and send them "
                              "invitations or connect with friends that are not on "
                              "the app using the invite link",
                          buttonTitle: "Search",
                          onPressed: () => _onSearchTapped(),
                        ),
                      ),
                    );
                  else
                    return RefreshIndicator(
                      onRefresh: onRefreshActivated,
                      child: ConnectorList(
                        controller: _controller,
                        connectors: connectorList,
                        onFetchMorePressed: () => _fetchMore(tryAgain: true),
                      ),
                    );
                } else if (state is ConnectionFailed) {
                  return SingleChildScrollView(
                    child: MessageDisplay(
                      fontSize: 18.0,
                      title: state.message,
                      description: "Please check your internet connection",
                      buttonTitle: "Try again",
                      onPressed: () => refreshData(),
                    ),
                  );
                }
                return Center(child: const CustomProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onRefreshActivated() async {
    final state = context.read<LoadMoreConnectorCubit>().state;
    if (state is! LoadingConnections) {
      await context.read<RefreshConnectionsCubit>().refresh(currentuserId);
    }
  }

  void refreshData() {
    context
        .read<RefreshConnectionsCubit>()
        .refresh(currentuserId, showIndicator: true);
  }

  void _onScroll() async {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    if (maxScroll - currentScroll <= 50 && !_controller.position.outOfRange) {
      _fetchMore();
    }
  }

  Future<void> loadMoreConnections(DocumentSnapshot lastDoc) async {
    // call the provider to fetch more users
    context
        .read<LoadMoreConnectorCubit>()
        .loadMoreConnections(currentuserId, lastDoc);
  }

  Future<void> _fetchMore({bool tryAgain = false}) async {
    final state = context.read<ConnectorCubit>().state;
    if (state is ConnectionsLoaded) {
      if (tryAgain) {
        loadMoreConnections(state.connectionModel.lastDoc!);
      } else {
        final loadMoreState = context.read<LoadMoreConnectorCubit>().state;
        if (loadMoreState is! LoadingConnections &&
            loadMoreState is! ConnectionFailed &&
            state.hasMore) {
          // check is the last documentId is available
          final lastDoc = state.connectionModel.lastDoc;
          if (lastDoc != null) {
            loadMoreConnections(lastDoc);
          } else {
            onRefreshActivated();
          }
        }
      }
    }
  }

  void _onSearchTapped() {
    Navigator.of(context).push<Widget>(
      PageTransition(
        child: BlocProvider(
          create: (_) => SearchConnBloc(SearchServiceImpl()),
          child: SearchScreen(),
        ),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }
}
