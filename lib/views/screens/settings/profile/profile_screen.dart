import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/inviter_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/invitation_service.dart';
import '../../../../services/user_service.dart';
import '../../../../utils/palette.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/image_utils.dart';
import '../../../../utils/navigate.dart';
import '../../../widgets/failure_widget.dart';
import '../../../widgets/progress_indicator.dart';
import '../widgets/items.dart';
import '../widgets/profile.dart';
import 'mutual_connection_screen.dart';
import 'widgets/connection_status_button.dart';

class ProfileScreen extends StatefulWidget {
  final PureUser user;
  final Inviter? inviter;
  final bool hideConnectionStatus;
  const ProfileScreen(
      {Key? key,
      required this.user,
      this.inviter,
      this.hideConnectionStatus = false})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _style = const TextStyle(
    fontSize: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) =>
              UserExtraCubit(UserServiceImpl())..getExtraData(widget.user.id),
        ),
        BlocProvider(
          create: (_) => SendInvitationCubit(
            InvitationServiceImp(isPersistentEnabled: false),
          ),
        ),
        BlocProvider(
          create: (_) => OtherReceivedActionsCubit(
            InvitationServiceImp(isPersistentEnabled: false),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(backgroundColor: secondaryColor),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ColoredBox(
                color: secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // profile
                      Center(child: ProfileSection(user: widget.user)),
                      const SizedBox(height: 16.0),

                      // connections count, connection status
                      BlocBuilder<UserExtraCubit, UserExtraState>(
                        builder: (context, state) {
                          if (state is UserExtraSuccess) {
                            final mutualConnList = mutualConnections(
                                state.extraData.connections.toList());
                            return Row(
                              children: [
                                Expanded(
                                  child: _SpecialItem(
                                    title: "Connections",
                                    count: state.extraData.totalConnection,
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    splashColor: Palette.tintColor,
                                    child: _SpecialItem(
                                      title: "Mutual Connections",
                                      count: mutualConnList.length,
                                    ),
                                    onTap: () =>
                                        viewMutualConnections(mutualConnList),
                                  ),
                                ),
                              ],
                            );
                          } else if (state is UserExtraFailure) {
                            return RefreshFailureWidget(
                              onTap: () => context
                                  .read<UserExtraCubit>()
                                  .getExtraData(widget.user.id),
                            );
                          }

                          return Center(
                              child: CustomProgressIndicator(size: 20));
                        },
                      ),

                      if (!widget.hideConnectionStatus)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ConnectionStatusButton(
                            user: widget.user,
                            inviter: widget.inviter,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TitleHeader(
                title: "About",
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.user.about!.isEmpty ? "--" : widget.user.about!,
                    style: _style.copyWith(
                      color: Theme.of(context).colorScheme.secondaryVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _Item(title: widget.user.username, image: ImageUtils.username),
              _Item(title: widget.user.location, image: ImageUtils.location),
              _Item(
                title: "Joined ${_formattedDate(widget.user.joinedDate!)}",
                image: ImageUtils.calendar,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  void viewMutualConnections(List<String> mutualConnections) {
    push(
      context: context,
      page: MutualConnectionsScreen(connections: mutualConnections),
    );
  }

  String _formattedDate(DateTime date) {
    return DateFormat("MMM dd, yyyy").format(date);
  }

  List<String> mutualConnections(List<String> viewedUserConn) {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (authState is Authenticated) {
      final currentUserConn = getConnections(authState.user.connections!);
      currentUserConn.removeWhere((item) => !viewedUserConn.contains(item));
      return currentUserConn;
    } else {
      return [];
    }
  }
}

class _SpecialItem extends StatelessWidget {
  final int count;
  final String title;
  const _SpecialItem({Key? key, required this.title, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        children: [
          Text(
            count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
          )
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String image;
  final String title;
  const _Item({Key? key, required this.title, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Image.asset(
            image,
            width: 24.0,
            height: 24.0,
            color: Theme.of(context).colorScheme.primaryVariant,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
