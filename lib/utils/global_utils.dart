class GlobalUtils {
  // local storage keys
  static String get onBoardingSharedPrefKey => 'onBoardingSharedPrefKey';
  static String get userSharedPrefKey => 'userDataPrefKey';
  static String get sentInvitationPrefKey => 'sentInvitationPrefKey';
  static String get receivedInvitationPrefKey => 'receivedInvitationPrefKey';
  static String get connectionsPrefKey => 'connectionsPrefKey';

  // Firebase collection and document names
  static String get userCollection => 'Users';
  static String get invitationCollection => 'Invitations';
  static String get connectionCollection => 'Connections';
  static String get messageCollection => 'Messages';
  static String get chatCollection => 'Chats';
  static String get receiptCollection => 'Receipts';
  static String get invitationLinkCollection => 'InvitationLinks';
  static String get userExtCollection => 'UsersExt';

  static Duration get timeOutInDuration =>
      const Duration(milliseconds: 20 * 1000);
  static Duration get updateTimeOutInDuration =>
      const Duration(milliseconds: 10 * 1000);
  static Duration get shortTimeOutInDuration =>
      const Duration(milliseconds: 5 * 1000);

  static Duration get imageUploadtimeOutInDuration =>
      const Duration(milliseconds: 30 * 1000);

  static int get maxFileUploadSizeInByte => 5 * 1024 * 1024;

  // limit of invitee list to fetch at once from the server.
  static const int inviteeListLimit = 20;
  static const int messagesLimit = 20;
  static const int cachedMessagesLimit = 50;
  static const int cachedChatsLimit = 30;
  static const int chatsLimit = 20;
  static const int LastFetchedchatsLimit = 70;
  static const int LastFetchedMessagesLimit = 500;
  static const int inviterListLimit = 20;

  // Topic name for notifications
  static const pureTopic = "pureNotifications";

  // Regular Expression
  // --------------------------------------------------------------------------
  static final String phoneRegExp =
      r"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$";
}
