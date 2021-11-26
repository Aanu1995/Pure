import 'package:algolia/algolia.dart';

import '../model/connection_model.dart';
import '../model/pure_user_model.dart';
import '../repositories/algolia_application.dart';
import '../repositories/connection.dart';
import '../utils/exception.dart';
import '../utils/global_utils.dart';
import '../utils/request_messages.dart';
import 'connection_service.dart';

abstract class SearchService {
  const SearchService();
  Future<bool> searchUsername(String username);
  Future<List<PureUser>> searchForUser(String searchQuery,
      {int pageNumber = 0, int hitsPerPage = 20});
  Future<List<Connector>> searchForFriends(
      String searchQuery, String currentUserId, List<String> friendsId);
}

class SearchServiceImpl extends SearchService {
  final Algolia? algoliaApp;
  final ConnectionRepo? connection;

  SearchServiceImpl({this.algoliaApp, this.connection}) {
    _algoliaApp = algoliaApp ?? AlgoliaApplication.algolia;
    _connection = connection ?? ConnectionRepoImpl();
  }

  late Algolia _algoliaApp;
  late ConnectionRepo _connection;

  ConnectionService _connectionService = ConnectionServiceImpl();

  @override
  Future<bool> searchUsername(String username) async {
    try {
      final attribute = "username";
      AlgoliaQuery query = _algoliaApp.instance
          .index(GlobalUtils.userCollection)
          .query(username);

      query = query.setExactOnSingleWordQuery(ExactOnSingleWordQuery.word);
      query = query.setAttributesToRetrieve([attribute]);
      AlgoliaQuerySnapshot querySnap = await query.getObjects();

      return !(querySnap.hits
          .any((element) => element.data[attribute] == username));
    } on AlgoliaError catch (_) {
      return false;
    }
  }

  @override
  Future<List<PureUser>> searchForUser(String searchQuery,
      {int pageNumber = 0, int hitsPerPage = 20}) async {
    // check internet connection
    await _connection.checkConnectivity();

    List<PureUser> users = [];
    try {
      AlgoliaQuery query = _algoliaApp.instance
          .index(GlobalUtils.userCollection)
          .query(searchQuery);

      query = query.setHitsPerPage(hitsPerPage);
      query = query.setPage(pageNumber);

      AlgoliaQuerySnapshot querySnap = await query.getObjects();
      for (final data in querySnap.hits) {
        users.add(PureUser.fromMap(data.data));
      }
      return users;
    } on AlgoliaError catch (_) {
      throw ServerException(message: ErrorMessages.generalMessage);
    } catch (_) {
      throw ServerException(message: ErrorMessages.generalMessage);
    }
  }

  Future<List<Connector>> searchForFriends(
      String searchQuery, String currentUserId, List<String> friendsId) async {
    List<Connector> friends = [];
    try {
      AlgoliaQuery query = _algoliaApp.instance
          .index(GlobalUtils.userCollection)
          .query(searchQuery);

      String value = friendsId.join(" OR userId:");
      value = "userId:$value";
      query = query.filters('($value)');

      AlgoliaQuerySnapshot querySnap = await query.getObjects();
      for (final data in querySnap.hits) {
        final connectorId = data.data["userId"] as String;
        final connectionId = _getConnectionId(
          CurrentUser.currentUserId,
          connectorId,
        );
        final result = await _connectionService.getConnection(connectionId);

        friends.add(Connector.fromMap(result, connectorId: connectorId));
      }
      return friends;
    } on AlgoliaError catch (_) {
      throw ServerException(message: ErrorMessages.generalMessage);
    } catch (_) {
      throw ServerException(message: ErrorMessages.generalMessage);
    }
  }

  String _getConnectionId(String firstId, String secondId) {
    if (firstId.compareTo(secondId) == -1) {
      return "${firstId}_${secondId}";
    } else {
      return "${secondId}_${firstId}";
    }
  }
}
