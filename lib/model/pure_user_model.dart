import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_enum.dart';

// this class is a singleton to make current user id accessible globally
class CurrentUser {
  factory CurrentUser() => _instance;

  CurrentUser._internal();

  static final CurrentUser _instance = CurrentUser._internal();

  static String _userId = '';

  static set setUserId(String id) {
    _userId = id;
  }

  static String get currentUserId => _userId;
}

// Received means you receive a connection request from another user
// Sent means you send a connection request to another user
// Connected means both of you are connected
enum ConnectionStatus { Received, Sent, Connected }

class PureUser extends Equatable {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final String photoURL;
  final String? about;
  final Map<String, ConnectionStatus>? connections;
  final bool isPrivate;
  final int? sentCounter; // for sent invitations
  final int? receivedCounter; // for received invitations
  final int? connectionCounter; // for connections
  final DateTime? joinedDate;

  const PureUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.photoURL,
    this.about,
    this.connections,
    this.isPrivate = false,
    this.connectionCounter,
    this.receivedCounter,
    this.sentCounter,
    this.joinedDate,
  });

  factory PureUser.fromMap(Map<String, dynamic> data) {
    Map<String, ConnectionStatus> connections = {};

    final connectionData = data['connections'] as Map<String, dynamic>?;
    if (connectionData != null) {
      for (final data in connectionData.entries) {
        connections.putIfAbsent(data.key, () => getStatus(data.value as int));
      }
    }

    return PureUser(
      id: data['userId'] as String,
      username: data["username"] as String? ?? "",
      email: data['email'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      photoURL: data['photoURL'] as String,
      location: data['location'] as String,
      about: data['about'] as String? ?? "",
      connections: connections,
      isPrivate: data['isPrivate'] as bool? ?? false,
      receivedCounter: data["receivedCounter"] as int? ?? 0,
      sentCounter: data["sentCounter"] as int? ?? 0,
      connectionCounter: data["connectionCounter"] as int? ?? 0,
      joinedDate: DateTime.parse(data['date'] as String).toLocal(),
    );
  }

  // Requires to perform manual update before the remote update
  PureUser copyWith({
    String? identifier,
    bool isSendInvitation = false,
    bool isReceiveInvitation = false,
    bool isWithdrawalInvitation = false,
    bool isIgnoreInvitation = false,
    bool isAcceptInvitation = false,
    bool isRemovedConnection = false,
  }) {
    final newConnections = connections!;
    int _receivedCounter = receivedCounter!;
    int _sentCounter = sentCounter!;
    int _connectionCounter = connectionCounter!;

    if (isSendInvitation && identifier != null) {
      newConnections[identifier] = ConnectionStatus.Sent;
      _sentCounter += 1;
    } else if (isReceiveInvitation && identifier != null) {
      newConnections[identifier] = ConnectionStatus.Received;
      _receivedCounter += 1;
    } else if (isWithdrawalInvitation) {
      _sentCounter -= 1;
    } else if (isIgnoreInvitation) {
      _receivedCounter -= 1;
      if (identifier != null) {
        newConnections.remove(identifier);
      }
    } else if (isAcceptInvitation) {
      _receivedCounter -= 1;
      _connectionCounter += 1;
      if (identifier != null) {
        newConnections[identifier] = ConnectionStatus.Connected;
      }
    } else if (isRemovedConnection) {
      _connectionCounter -= 1;
      if (identifier != null) {
        newConnections.remove(identifier);
      }
    }

    return PureUser(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photoURL: photoURL,
      location: location,
      about: about,
      connections: newConnections,
      isPrivate: isPrivate,
      receivedCounter: _receivedCounter,
      sentCounter: _sentCounter,
      connectionCounter: _connectionCounter,
      joinedDate: joinedDate,
    );
  }

  static Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      'userId': user.uid,
      'username': '',
      'email': user.email,
      'firstName': '',
      'lastName': '',
      'location': '',
      'about': '',
      'photoURL': user.photoURL ?? '',
      'date': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toSaveMap() {
    return <String, dynamic>{
      'userId': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'about': about,
      'photoURL': photoURL,
      "isPrivate": isPrivate,
      'date': joinedDate!.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'about': about,
    };
  }

  String get fullName =>
      firstName.isEmpty ? 'New User' : '$firstName $lastName';

  bool get isMe => id == CurrentUser.currentUserId;

  ConnectionAction checkConnectionAction(String userId) {
    if (connections!.keys.toList().contains(userId)) {
      switch (connections![userId]) {
        case ConnectionStatus.Sent:
          return ConnectionAction.PENDING;
        case ConnectionStatus.Received:
          return ConnectionAction.ACCEPT;
        case ConnectionStatus.Connected:
          return ConnectionAction.MESSAGE;
        default:
          return ConnectionAction.CONNECT;
      }
    }
    return ConnectionAction.CONNECT;
  }

  static ConnectionStatus getStatus(int status) {
    switch (status) {
      case 0:
        return ConnectionStatus.Sent;
      case 1:
        return ConnectionStatus.Received;
      case 2:
        return ConnectionStatus.Connected;
      default:
        return ConnectionStatus.Sent;
    }
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        photoURL,
        location,
        about,
        connections,
        receivedCounter,
        sentCounter,
        connectionCounter,
      ];
}
