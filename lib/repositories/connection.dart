import '../utils/exception.dart';
import '../utils/request_messages.dart';

abstract class ConnectionRepo {
  Future<bool> checkConnection();
  Future<bool> checkConnectivity();
}

class ConnectionRepoImpl implements ConnectionRepo {
  // The test to actually see if there is a connection
  @override
  Future<bool> checkConnection() async {
    // removes network connection because it affects requests time...
    // replaces it by adding connection timeout
    return true;
  }

  // checks connectivity status
  @override
  Future<bool> checkConnectivity() async {
    if (!await checkConnection()) {
      return throw NetworkException(
          message: ErrorMessages.internetconnectionMessage);
    }
    return true;
  }
}
