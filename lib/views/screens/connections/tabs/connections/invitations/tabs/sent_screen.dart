import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../blocs/bloc.dart';
import '../../../../../../../model/invitation_model.dart';
import '../../../../../../../model/pure_user_model.dart';
import '../../../../../../widgets/failure_widget.dart';
import '../../../../../../widgets/message_widget.dart';
import '../../../../../../widgets/progress_indicator.dart';
import '../../../../../../widgets/snackbars.dart';
import '../../../../../../widgets/user_profile_provider.dart';
import '../../../../widgets/load_more.dart';
import '../widgets/invitee_profile.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({Key? key}) : super(key: key);

  @override
  _SentScreenState createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = ScrollController();

  ///  Listeners

  void loadMoreListener(BuildContext context, SentInvitationState state) {
    if (state is InviteesLoaded) {
      context
          .read<SentInvitationCubit>()
          .updateInvitees(state.inviteeModel, state.hasMore);
    }
  }

  void otherActionListener(BuildContext context, SentInvitationState state) {
    if (state is Withdrawing) {
      context.read<SentInvitationCubit>().delete(state.index);
    } else if (state is Withdrawed) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser =
            authState.user.copyWith(isWithdrawalInvitation: true);
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
    } else if (state is WithdrawalFailed) {
      showFailureFlash(
        context,
        "Failed to withdraw invitation",
        backgroundColor: Color(0xFF04192F),
        position: FlashPosition.top,
      );
      context
          .read<SentInvitationCubit>()
          .addInviteeBack(state.index, state.invitee);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
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
        BlocListener<LoadMoreInviteeCubit, SentInvitationState>(
          listener: loadMoreListener,
        ),
        BlocListener<OtherActionsInvitationCubit, SentInvitationState>(
          listener: otherActionListener,
        )
      ],
      child: Column(
        children: [
          // shows failure widget when refreshing invitee list failed
          BlocBuilder<LoadMoreInviteeCubit, SentInvitationState>(
            builder: (context, state) {
              if (state is RefreshingInvitees) {
                return RefreshLoadingWidget();
              } else if (state is InviteeRefreshFailed) {
                return RefreshFailureWidget(onTap: () => onRefreshFailed());
              }
              return Offstage();
            },
          ),

          Expanded(
            child: BlocBuilder<SentInvitationCubit, SentInvitationState>(
              builder: (context, state) {
                if (state is InviteesLoaded) {
                  final inviteeList = state.inviteeModel.invitees;
                  if (inviteeList.isEmpty)
                    return MessageDisplay(
                      fontSize: 18.0,
                      title: "You've not sent any invitations",
                      description:
                          "Search for connections using the search field",
                      buttonTitle: "Back",
                      onPressed: () => Navigator.of(context).pop(),
                    );
                  else
                    return RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.custom(
                        controller: _controller,
                        padding: EdgeInsets.all(0),
                        physics: AlwaysScrollableScrollPhysics(),
                        childrenDelegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (inviteeList.length == index)
                              return LoadMoreInvitees(
                                onTap: () => _fetchMore(tryAgain: true),
                              );
                            else {
                              final invitee =
                                  state.inviteeModel.invitees[index];
                              return KeepAlive(
                                key: ValueKey<String>(invitee.invitationId),
                                keepAlive: true,
                                child: ProfileProvider(
                                  userId: invitee.inviteeId,
                                  child: InviteeProfile(
                                    invitee: invitee,
                                    itemIndex: index,
                                    // only show separator if there is another item below
                                    showSeparator:
                                        index < (inviteeList.length - 1),
                                  ),
                                ),
                              );
                            }
                          },
                          childCount: inviteeList.length + 1,
                          findChildIndexCallback: (Key key) {
                            final ValueKey<String> valueKey =
                                key as ValueKey<String>;
                            final String data = valueKey.value;
                            return inviteeList
                                .map((e) => e.invitationId)
                                .toList()
                                .indexOf(data);
                          },
                        ),
                      ),
                    );
                } else if (state is InviteeLoadingFailed) {
                  return MessageDisplay(
                    fontSize: 18.0,
                    title: state.message,
                    description: "Please check your internet connection",
                    buttonTitle: "Try again",
                    onPressed: () => tryAgain(),
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

  Future<void> onRefresh() async {
    // delay is added to enable refresh indicator go round once
    await Future<void>.delayed(Duration(milliseconds: 300));
    final state = context.read<LoadMoreInviteeCubit>().state;
    if (state is! LoadingInvitees) {
      await context
          .read<LoadMoreInviteeCubit>()
          .refresh(CurrentUser.currentUserId);
    }
  }

  void _onScroll() async {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    if (maxScroll - currentScroll <= 50 && !_controller.position.outOfRange) {
      _fetchMore();
    }
  }

  Future<void> loadAgain(InviteeModel inviteeModel) async {
    // call the provider to fetch more users
    await context
        .read<LoadMoreInviteeCubit>()
        .loadMoreInvitees(CurrentUser.currentUserId, inviteeModel);
  }

  Future<void> _fetchMore({bool tryAgain = false}) async {
    final state = context.read<SentInvitationCubit>().state;
    if (state is InviteesLoaded) {
      if (tryAgain) {
        loadAgain(state.inviteeModel);
      } else {
        final loadMoreState = context.read<LoadMoreInviteeCubit>().state;
        if (loadMoreState is! LoadingInvitees &&
            state is! InviteeLoadingFailed &&
            state.hasMore) {
          // check is the last documentId is available
          if (state.inviteeModel.lastDocs != null) {
            loadAgain(state.inviteeModel);
          } else {
            onRefresh();
          }
        }
      }
    }
  }

  void tryAgain() {
    BlocProvider.of<SentInvitationCubit>(context)
        .loadFromremoteStorage(CurrentUser.currentUserId);
  }

  void onRefreshFailed() {
    context
        .read<LoadMoreInviteeCubit>()
        .refresh(CurrentUser.currentUserId, showIndicator: true);
  }
}
