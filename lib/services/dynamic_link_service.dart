import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pure/model/pure_user_model.dart';
import 'package:uuid/uuid.dart';

import '../model/invitation_model.dart';
import '../utils/exception.dart';
import '../utils/flavors.dart';
import '../utils/global_utils.dart';
import '../utils/request_messages.dart';

abstract class DynamicLinkService {
  const DynamicLinkService();
  Future<String> shareUserInviteLink(PureUser inviter);
}

class DynamicLinkServiceImpl extends DynamicLinkService {
  final FirebaseFirestore? firestore;

  DynamicLinkServiceImpl({this.firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _firestore.settings = Settings(persistenceEnabled: false);
    _invitationLinkCollection =
        _firestore.collection(GlobalUtils.invitationLinkCollection);
  }

  late FirebaseFirestore _firestore;
  late CollectionReference _invitationLinkCollection;

  Future<String> _generateLink(
      {required String title,
      required String path,
      String? description,
      Map<String, dynamic>? parameter,
      String? imageURL}) async {
    Uri outgoingUri = new Uri(
      scheme: 'https',
      host: 'annulus.com',
      path: path,
      queryParameters: parameter,
    );
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: F.dynamicLinkUriPrefix!,
      link: outgoingUri,
      androidParameters: AndroidParameters(
        packageName: F.appId,
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: F.appId,
        minimumVersion: '1',
        appStoreId: F.appStoreId,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        description: description,
        imageUrl: imageURL != null ? Uri.parse(imageURL) : null,
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    return shortDynamicLink.shortUrl.toString();
  }

  // Share your boat card via a link
  @override
  Future<String> shareUserInviteLink(PureUser inviter) async {
    EasyLoading.show(status: "loading..."); // show loading indicator

    // generate the link
    final invitationId = Uuid().v4();
    final model = InvitationModel(
      senderId: inviter.id,
      receiverId: "",
    );

    await _invitationLinkCollection
        .doc(invitationId)
        .set(model.toInviteLinkMap(invitationId))
        .timeout(GlobalUtils.updateTimeOutInDuration);

    String link = await _generateLink(
      title: "You've been invited to Pure",
      path: '/invitation',
      description: "${inviter.fullName} has invited you to connect on Pure",
      parameter: <String, String>{
        "invitationId": invitationId,
        "senderId": inviter.id,
      },
    );
    EasyLoading.dismiss(); // dismiss indicator once link is generated
    return link;
  }

  /// Helper methods

  // check if the invitation link exists
  Future<bool> checkIfInviteLinkExists(String invitationId) async {
    try {
      final receiverId = CurrentUser.currentUserId;
      final snapshot = await _invitationLinkCollection
          .doc(invitationId)
          .get()
          .timeout(GlobalUtils.updateTimeOutInDuration);
      if (snapshot.exists) {
        await _invitationLinkCollection.doc(invitationId).update({
          "receiverId": receiverId,
          "sentDate": DateTime.now().toUtc().toIso8601String(),
          "members": FieldValue.arrayUnion(<String>[receiverId])
        });
        return true;
      }
      return false;
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }
}
