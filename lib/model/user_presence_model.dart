import 'package:equatable/equatable.dart';

import '../utils/true_time.dart';

class UserPresenceModel extends Equatable {
  final bool isOnline;
  final DateTime lastSeen;

  const UserPresenceModel({required this.isOnline, required this.lastSeen});

  factory UserPresenceModel.fromMap(Map<String, dynamic> data) {
    return UserPresenceModel(
      isOnline: data['isOnline'] as bool,
      lastSeen: DateTime.parse(data['lastSeen'] as String),
    );
  }

  static UserPresenceModel onError() {
    return UserPresenceModel(isOnline: false, lastSeen: TrueTime.now());
  }

  static Map<String, dynamic> onlineData() {
    return <String, dynamic>{
      'isOnline': true,
      "lastSeen": TrueTime.now().toUtc().toIso8601String()
    };
  }

  static Map<String, dynamic> offlineData() {
    return <String, dynamic>{
      'isOnline': false,
      "lastSeen": TrueTime.now().toUtc().toIso8601String()
    };
  }

  @override
  List<Object?> get props => [isOnline, lastSeen];
}
