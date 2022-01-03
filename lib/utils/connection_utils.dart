import '../model/connection_model.dart';

List<Connector> orderedSetForConnections(final List<Connector> connectors) {
  final result = connectors.toList();
  final connectionsId = Set<String>();
  result.retainWhere((x) => connectionsId.add(x.connectionId));
  return [...result.toList()];
}
