import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/utils/app_theme.dart';

import '../../../../../../../blocs/bloc.dart';
import '../../../../../../../model/inviter_model.dart';
import '../../../../../../../model/pure_user_model.dart';
import '../../../../../../../utils/app_utils.dart';
import '../../../../../../widgets/avatar.dart';
import '../../../../../../widgets/shimmers/loading_shimmer.dart';

class InviterProfile extends StatelessWidget {
  final Inviter inviter;
  final int itemIndex;
  final bool showSeparator;
  const InviterProfile({
    Key? key,
    required this.inviter,
    required this.itemIndex,
    this.showSeparator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSuccess) {
          final user = state.user;
          return Column(
            children: [
              ListTile(
                onTap: () => viewFullProfile(context, user, inviter),
                contentPadding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                horizontalTitleGap: 4.0,
                leading: Avartar(size: 40.0, imageURL: user.photoURL),
                title: Text(
                  user.fullName,
                  key: ValueKey(inviter.invitationId),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
                  ),
                ),
                subtitle: Text(
                  "Received ${getFormattedDate(inviter.receivedDate!)}",
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: SizedBox(
                  width: 110.0,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () =>
                            onInvitationIgnored(context, itemIndex, inviter),
                        icon: Icon(
                          CupertinoIcons.clear_circled,
                          size: 42.0,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      IconButton(
                        onPressed: () => onInvitationAccepted(
                          context,
                          user.fullName,
                          itemIndex,
                          inviter,
                        ),
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          CupertinoIcons.check_mark_circled,
                          size: 42.0,
                          color: Palette.greenColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showSeparator) const Divider(height: 0.0),
            ],
          );
        }
        return const SingleShimmer();
      },
    );
  }

  void viewFullProfile(
      BuildContext context, final PureUser user, Inviter inviter) {
    // push(
    //     context: context,
    //     page: ProfilePublicView(viewer: user, inviter: inviter));
  }

  Future<void> onInvitationIgnored(
      BuildContext context, int inviterIndex, Inviter inviter) async {
    final state = context.read<OtherReceivedActionsCubit>().state;
    if (state is! Processing) {
      context
          .read<OtherReceivedActionsCubit>()
          .ignoreInvitation(inviterIndex, inviter);
    }
  }

  Future<void> onInvitationAccepted(
    BuildContext context,
    String username,
    int inviterIndex,
    Inviter inviter,
  ) async {
    final state = context.read<OtherReceivedActionsCubit>().state;
    if (state is! Processing) {
      context
          .read<OtherReceivedActionsCubit>()
          .acceptInvitation(inviterIndex, username, inviter);
    }
  }
}
