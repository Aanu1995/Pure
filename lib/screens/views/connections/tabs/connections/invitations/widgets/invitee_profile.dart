import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../blocs/bloc.dart';
import '../../../../../../../model/invitee_model.dart';
import '../../../../../../../model/pure_user_model.dart';
import '../../../../../../../utils/app_utils.dart';
import '../../../../../../../utils/navigate.dart';
import '../../../../../../widgets/avatar.dart';
import '../../../../../../widgets/shimmers/loading_shimmer.dart';
import '../../../../../settings/profile/profile_screen.dart';

class InviteeProfile extends StatelessWidget {
  final Invitee invitee;
  final int itemIndex;
  final bool showSeparator;

  const InviteeProfile({
    Key? key,
    required this.itemIndex,
    required this.invitee,
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
                onTap: () => viewFullProfile(context, user),
                contentPadding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                horizontalTitleGap: 4.0,
                leading: Avartar(size: 40.0, imageURL: user.photoURL),
                title: Text(
                  user.fullName,
                  key: ValueKey(invitee.invitationId),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.15,
                  ),
                ),
                subtitle: Text(
                  "Sent ${getFormattedDate(invitee.sentDate!)}",
                  key: ValueKey(invitee.invitationId),
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: SizedBox(
                  width: 150.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => onWithDrawPressed(
                          context,
                          itemIndex,
                          user.fullName,
                          invitee,
                        ),
                        padding: const EdgeInsets.only(left: 4.0),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.secondaryVariant,
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

  void viewFullProfile(BuildContext context, final PureUser user) {
    push(context: context, page: ProfileScreen(user: user));
  }

  Future<void> onWithDrawPressed(BuildContext context, int inviteeIndex,
      String fullName, Invitee invitee) async {
    final state = context.read<OtherActionsInvitationCubit>().state;
    if (state is! Withdrawing) {
      final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Withdraw invitation?',
        message: 'Would you like to withdraw the invitation sent to $fullName?',
        okLabel: "Withdraw",
        isDestructiveAction: true,
      );

      if (result == OkCancelResult.ok) {
        context
            .read<OtherActionsInvitationCubit>()
            .withdrawInvitation(inviteeIndex, invitee);
      }
    }
  }
}
