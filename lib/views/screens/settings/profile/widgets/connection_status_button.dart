import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/app_enum.dart';
import '../../../../../model/connection_model.dart';
import '../../../../../model/invitation_model.dart';
import '../../../../../model/inviter_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/palette.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/snackbars.dart';
import '../../../chats/messages/messages_screen.dart';

class ConnectionStatusButton extends StatelessWidget {
  final PureUser user;
  final Inviter? inviter;

  const ConnectionStatusButton({Key? key, required this.user, this.inviter})
      : super(key: key);

  final _style = const TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

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

  void otherActionListener(
      BuildContext context, ReceivedInvitationState state) {
    if (state is Accept) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user
            .copyWith(isAcceptInvitation: true, identifier: user.id);
        BlocProvider.of<AuthCubit>(context).update(currentUser);
      }
      final message = "You and ${state.fullName} are now connected";
      showSuccessFlash(context, message);

      removeInviterOnAcceptedOrIgnored(context);
      addConnectorOnAccepted(context, state.inviter);
    } else if (state is Ignored) {
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is Authenticated) {
        final currentUser = authState.user
            .copyWith(isIgnoreInvitation: true, identifier: user.id);
        BlocProvider.of<AuthCubit>(context).update(currentUser);
        removeInviterOnAcceptedOrIgnored(context);
      }
    } else if (state is OtherActionFailed) {
      showFailureFlash(
        context,
        "Oops! something went wrong",
        backgroundColor: Color(0xFF04192F),
        position: FlashPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SendInvitationCubit, SendInvitationState>(
          listener: sendInvitationListener,
        ),
        BlocListener<OtherReceivedActionsCubit, ReceivedInvitationState>(
          listener: otherActionListener,
        )
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (prev, current) =>
            (prev is Authenticated && current is Authenticated) &&
            prev.user != current.user,
        builder: (context, state) {
          if (state is Authenticated) {
            final status = state.user.checkConnectionAction(user.id);
            if (status == ConnectionAction.MESSAGE) {
              // connected
              return CustomOutlinedButton(
                width: 1.sw,
                height: 40.0,
                title: "Message",
                side: BorderSide(color: Palette.tintColor),
                shape: const StadiumBorder(),
                style: _style,
                onPressed: () => onMessageTapped(context, user),
              );
            } else if (status == ConnectionAction.PENDING) {
              // pending
              return CustomButton(
                width: 1.sw,
                height: 40.0,
                title: "Pending",
                style: _style.copyWith(
                  color: Theme.of(context).colorScheme.surface,
                ),
                shape: const StadiumBorder(),
                backgroundColor: Palette.tintColor,
                onPressed: () {},
              );
            } else if (status == ConnectionAction.ACCEPT && inviter != null) {
              return Row(
                children: [
                  Expanded(
                    child: CustomOutlinedButton(
                      height: 40.0,
                      title: "Ignore",
                      style: _style,
                      shape: const StadiumBorder(),
                      side: BorderSide(color: Palette.tintColor),
                      onPressed: () =>
                          onInvitationIgnored(context, 0, inviter!),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: CustomButton(
                      height: 40.0,
                      title: "Accept",
                      style: _style.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      shape: const StadiumBorder(),
                      backgroundColor: Palette.tintColor,
                      onPressed: () => onInvitationAccepted(
                          context, 0, user.fullName, inviter!),
                    ),
                  ),
                ],
              );
            } else if (status == ConnectionAction.CONNECT) {
              // Not connected
              if (user.isPrivate)
                return Offstage();
              else
                return CustomButton(
                  width: 1.sw,
                  height: 40.0,
                  onPressed: () => sendConnectionRequest(context, user.id),
                  shape: const StadiumBorder(),
                  style: _style.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  backgroundColor: Palette.tintColor,
                  title: "Connect",
                );
            }
          }
          return Offstage();
        },
      ),
    );
  }

  void onMessageTapped(BuildContext context, PureUser user) {
    // gets the chatId using the id of the two users
    final chatId = InvitationModel.getInvitationId(
      user.id,
      CurrentUser.currentUserId,
    );
    push(
      context: context,
      rootNavigator: true,
      page: MessagesScreen(chatId: chatId, receipient: user),
    );
  }

  void sendConnectionRequest(BuildContext context, String receiverId) {
    final state = BlocProvider.of<SendInvitationCubit>(context).state;
    if (state is! SendingInvitation) {
      final data = InvitationModel(
          senderId: CurrentUser.currentUserId, receiverId: receiverId);
      BlocProvider.of<SendInvitationCubit>(context)
          .sendInvitation(data.toMap());
    }
  }

  Future<void> onInvitationIgnored(
      BuildContext context, int inviterIndex, Inviter inviter) async {
    final state = BlocProvider.of<OtherReceivedActionsCubit>(context).state;
    if (state is! Processing) {
      context
          .read<OtherReceivedActionsCubit>()
          .ignoreInvitation(inviterIndex, inviter);
    }
  }

  Future<void> onInvitationAccepted(
    BuildContext context,
    int inviterIndex,
    String fullName,
    Inviter inviter,
  ) async {
    final state = context.read<OtherReceivedActionsCubit>().state;
    if (state is! Processing) {
      context
          .read<OtherReceivedActionsCubit>()
          .acceptInvitation(inviterIndex, fullName, inviter);
    }
  }

  /// Theses are used to update the state of the
  void removeInviterOnAcceptedOrIgnored(BuildContext context) {
    final state = BlocProvider.of<ReceivedInvitationCubit>(context).state;
    if (state is InvitersLoaded) {
      final inviters = state.inviterModel.inviters.toList();
      final inviterIndex =
          inviters.indexWhere((inviter) => inviter.inviterId == user.id);

      BlocProvider.of<ReceivedInvitationCubit>(context).delete(inviterIndex);
    }
  }

  void addConnectorOnAccepted(BuildContext context, Inviter inviter) {
    BlocProvider.of<ConnectorCubit>(context)
        .addConnectionBack(0, Connector.fromInviter(inviter));
  }
}
