import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../widgets/failure_widget.dart';
import '../../../widgets/progress_indicator.dart';
import '../../../widgets/shimmers/loading_shimmer.dart';
import '../../../widgets/snackbars.dart';
import '../widgets/message_widget.dart';
import 'widgets/search_user_profile.dart';

class SearchAllConnectionResults extends StatefulWidget {
  final String title;
  const SearchAllConnectionResults({Key? key, required this.title})
      : super(key: key);

  @override
  _SearchAllConnectionResultsState createState() =>
      _SearchAllConnectionResultsState();
}

class _SearchAllConnectionResultsState
    extends State<SearchAllConnectionResults> {
  ScrollController _controller = ScrollController();

  void _onScroll() async {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    if (maxScroll - currentScroll <= 50 && !_controller.position.outOfRange) {
      _fetchMore();
    }
  }

  void _fetchMore() async {
    final state = BlocProvider.of<SeeAllUsersCubit>(context).state;
    if (state is SearchConnSuccess) {
      final loadMoreState = BlocProvider.of<LoadMoreUsersCubit>(context).state;
      if (loadMoreState is! SearchConnLoading && state.hasMore) {
        // call the provider to fetch more users
        await BlocProvider.of<LoadMoreUsersCubit>(context).loadMoreUsers(
          state.users,
          state.query,
          state.currentPageNumber + 1,
        );
      }
    }
  }

  void loadMoreListener(BuildContext context, SearchConnectionState state) {
    if (state is SearchConnSuccess) {
      context.read<SeeAllUsersCubit>().updateConnections(
            state.users,
            state.query,
            state.currentPageNumber,
            hasMore: state.hasMore,
          );
    }
  }

  void sendInvitationListener(BuildContext context, SendInvitationState state) {
    if (state is InvitationSent) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user.copyWith(
          identifier: state.receiverId,
          isSendInvitation: true,
        );
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
    } else if (state is InvitationSentfailure) {
      showFailureFlash(
        context,
        "Connection request failed",
        position: FlashPosition.top,
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: MultiBlocListener(
                listeners: [
                  BlocListener<SendInvitationCubit, SendInvitationState>(
                    listener: sendInvitationListener,
                  ),
                  BlocListener<LoadMoreUsersCubit, SearchConnectionState>(
                    listener: loadMoreListener,
                  )
                ],
                child: BlocBuilder<SeeAllUsersCubit, SearchConnectionState>(
                  builder: (context, state) {
                    if (state is SearchConnSuccess) {
                      final users = state.users;
                      if (users.isEmpty) return MessageDisplay();

                      return ListView.separated(
                        controller: _controller,
                        itemCount: users.length + 1,
                        padding: EdgeInsets.all(0),
                        separatorBuilder: (context, index) {
                          return Divider(height: 0.0);
                        },
                        itemBuilder: (context, index) {
                          if (users.length == index)
                            return _LoadMoreWidget(onTap: () => _fetchMore);
                          else {
                            final user = users[index];
                            return DetailedUserProfile(
                              key: ObjectKey(user),
                              viewer: user,
                            );
                          }
                        },
                      );
                    }
                    if (state is SearchConnFailure) {
                      return MessageDisplay(
                        title: state.message,
                        description: "Please check your connection",
                        buttonTitle: "Try again",
                        onPressed: () => tryAgain(),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LoadingShimmer(itemCount: 6),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void tryAgain() {
    BlocProvider.of<SeeAllUsersCubit>(context).searchUsers(widget.title);
  }
}

class _LoadMoreWidget extends StatelessWidget {
  final void Function()? onTap;
  const _LoadMoreWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<LoadMoreUsersCubit, SearchConnectionState>(
          builder: (context, state) {
            if (state is SearchConnLoading) {
              return SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CustomProgressIndicator(size: 16.0));
            } else if (state is SearchConnFailure) {
              return LoadMoreErrorWidget(
                onTap: onTap,
                message: "Failed to load more",
              );
            }
            return Offstage();
          },
        ),
      ),
    );
  }
}
