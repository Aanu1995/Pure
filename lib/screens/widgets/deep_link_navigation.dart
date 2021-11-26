import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../app.dart';
import '../../blocs/bloc.dart';
import '../../services/dynamic_link_service.dart';

class DeepLinkNavigation {
  static void deepLinkRoute(Uri? deepLink) {
    if (deepLink != null) {
      switch (deepLink.path) {
        case "/invitation":
          return _navigateToInvitorProfile(deepLink.queryParameters);
        default:
      }
    }
  }

  static void _navigateToInvitorProfile(Map<String, dynamic> data) async {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Checks if the user trying to use the link is not already connected
        // with the invitor
        final state = BlocProvider.of<AuthCubit>(context).state;
        final invitationId = data["invitationId"] as String;
        final inviterId = data['senderId'] as String;

        if (state is Authenticated &&
            inviterId != state.user.id &&
            state.user.connections!.containsKey(inviterId) == false) {
          // if not connected with the invitor
          final dynamicLinkService = DynamicLinkServiceImpl();
          //final userService = UserServiceImpl();

          final result =
              await dynamicLinkService.checkIfInviteLinkExists(invitationId);
          if (result) {
            try {
              // EasyLoading.show();
              // final user = await userService
              //     .getUser(inviterId)
              //     .timeout(GlobalUtils.updateTimeOutInDuration);
              // EasyLoading.dismiss();

              // BlocProvider.of<AuthCubit>(context).emit(Authenticated(state.user
              //     .copyWith(isReceiveInvitation: true, identifier: inviterId)));

              // push(context: context, page: Container());
            } catch (_) {
              EasyLoading.dismiss();
            }
          } else {
            showOkAlertDialog(
              context: context,
              title: "Invalid Link",
              message: "The link you clicked has either expired or invalid",
            );
          }
        }
      }
    } catch (e) {}
  }
}
