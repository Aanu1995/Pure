import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../blocs/bloc.dart';
import '../../../../../../../model/connection_model.dart';
import '../../../../../../../model/invitation_model.dart';
import '../../../../../../../model/pure_user_model.dart';
import '../../../../../../widgets/custom_keep_alive.dart';
import '../../../../../../widgets/failure_widget.dart';
import '../../../../../../widgets/message_widget.dart';
import '../../../../../../widgets/progress_indicator.dart';
import '../../../../../../widgets/snackbars.dart';
import '../../../../../../widgets/user_profile_provider.dart';
import '../../../../widgets/load_more.dart';
import '../widgets/inviter_profile.dart';

class ReceivedScreen extends StatefulWidget {
  const ReceivedScreen({Key? key}) : super(key: key);

  @override
  _ReceivedScreenState createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends State<ReceivedScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = ScrollController();
  late String currentUserId;
  final _desc = "You will be notified when an invitation arrives";

  @override
  void initState() {
    super.initState();
    currentUserId = CurrentUser.currentUserId;
    _controller.addListener(_onScroll);
    refreshData(); // refreshes data to be in sync with remote data
  }

  ///  Listeners

  void loadMoreListener(BuildContext context, ReceivedInvitationState state) {
    if (state is InvitersLoaded) {
      context
          .read<ReceivedInvitationCubit>()
          .updateOldInviters(state.inviterModel, state.hasMore);
    }
  }

  void refreshListener(BuildContext context, ReceivedInvitationState state) {
    if (state is InvitersLoaded) {
      context
          .read<ReceivedInvitationCubit>()
          .updateNewInviters(state.inviterModel);
    }
  }

  void otherActionListener(
      BuildContext context, ReceivedInvitationState state) {
    if (state is Processing) {
      context.read<ReceivedInvitationCubit>().delete(state.index);
    } else if (state is Accept) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user.copyWith(
          isAcceptInvitation: true,
          identifier: state.inviter.inviterId,
        );
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
      BlocProvider.of<ConnectorCubit>(context).addConnectionBack(
        0,
        Connector.fromInviter(state.inviter),
      );
      final message = "You and ${state.fullName} are now connected";
      showSuccessFlash(context, message);
    } else if (state is Ignored) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user.copyWith(isIgnoreInvitation: true);
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
    } else if (state is OtherActionFailed) {
      showFailureFlash(
        context,
        "Oops! something went wrong",
        backgroundColor: Color(0xFF04192F),
        position: FlashPosition.top,
      );
      context
          .read<ReceivedInvitationCubit>()
          .addInviterBack(state.index, state.inviter);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<LoadMoreInviterCubit, ReceivedInvitationState>(
          listener: loadMoreListener,
        ),
        BlocListener<RefreshInviterCubit, ReceivedInvitationState>(
          listener: refreshListener,
        ),
        BlocListener<OtherReceivedActionsCubit, ReceivedInvitationState>(
          listener: otherActionListener,
        )
      ],
      child: Column(
        children: [
          // shows failure widget when refreshing invitee list failed
          BlocBuilder<RefreshInviterCubit, ReceivedInvitationState>(
            builder: (context, state) {
              if (state is RefreshingInviters) {
                return RefreshLoadingWidget();
              } else if (state is InviterRefreshFailed) {
                return RefreshFailureWidget(onTap: () => refreshData());
              }
              return Offstage();
            },
          ),

          Expanded(
            child:
                BlocBuilder<ReceivedInvitationCubit, ReceivedInvitationState>(
              builder: (context, state) {
                if (state is InvitersLoaded) {
                  final inviterList = state.inviterModel.inviters;
                  if (inviterList.isEmpty)
                    return MessageDisplay(
                      fontSize: 18.0,
                      title: "You've not received any invitations yet",
                      description: _desc,
                      buttonTitle: "Back",
                      onPressed: () => Navigator.of(context).pop(),
                    );
                  else
                    return RefreshIndicator(
                      onRefresh: onRefreshActivated,
                      child: ListView.custom(
                        controller: _controller,
                        padding: EdgeInsets.all(0),
                        physics: AlwaysScrollableScrollPhysics(),
                        childrenDelegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (inviterList.length == index)
                              return LoadMoreInviters(
                                onTap: () => _fetchMore(tryAgain: true),
                              );
                            else {
                              final inviter =
                                  state.inviterModel.inviters[index];
                              return CustomKeepAlive(
                                key: ValueKey<String>(inviter.invitationId),
                                child: ProfileProvider(
                                  userId: inviter.inviterId,
                                  child: InviterProfile(
                                    inviter: inviter,
                                    itemIndex: index,
                                    // only show separator if there is another item below
                                    showSeparator:
                                        index < (inviterList.length - 1),
                                  ),
                                ),
                              );
                            }
                          },
                          childCount: inviterList.length + 1,
                          findChildIndexCallback: (Key key) {
                            final ValueKey<String> valueKey =
                                key as ValueKey<String>;
                            final String data = valueKey.value;
                            return inviterList
                                .map((e) => e.invitationId)
                                .toList()
                                .indexOf(data);
                          },
                        ),
                      ),
                    );
                } else if (state is InviterLoadingFailed) {
                  return MessageDisplay(
                    fontSize: 18.0,
                    title: state.message,
                    description: "Please check your internet connection",
                    buttonTitle: "Try again",
                    onPressed: () => refreshData(),
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
    final state = context.read<LoadMoreInviterCubit>().state;
    if (state is! LoadingInviters) {
      await context.read<RefreshInviterCubit>().refresh(currentUserId);
    }
  }

  void _onScroll() async {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    if (maxScroll - currentScroll <= 50 && !_controller.position.outOfRange) {
      _fetchMore();
    }
  }

  void refreshData() {
    context
        .read<RefreshInviterCubit>()
        .refresh(currentUserId, showIndicator: true);
  }

  Future<void> loadMoreInviters(InviterModel inviterModel) async {
    // call the provider to fetch more users
    context
        .read<LoadMoreInviterCubit>()
        .loadMoreInvitees(currentUserId, inviterModel);
  }

  Future<void> _fetchMore({bool tryAgain = false}) async {
    final state = context.read<ReceivedInvitationCubit>().state;
    if (state is InvitersLoaded) {
      if (tryAgain) {
        loadMoreInviters(state.inviterModel);
      } else {
        final loadMoreState = context.read<LoadMoreInviterCubit>().state;
        if (loadMoreState is! LoadingInviters &&
            loadMoreState is! InviterLoadingFailed &&
            state.hasMore) {
          // check is the last documentId is available
          if (state.inviterModel.lastDoc != null) {
            loadMoreInviters(state.inviterModel);
          } else {
            onRefreshActivated();
          }
        }
      }
    }
  }
}
