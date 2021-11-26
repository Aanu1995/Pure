import 'package:equatable/equatable.dart';

import '../../../model/pure_user_model.dart';

/// States for Search
class SearchConnectionState extends Equatable {
  const SearchConnectionState();

  @override
  List<Object?> get props => [];
}

class SearchConnEmpty extends SearchConnectionState {}

class SearchConnLoading extends SearchConnectionState {}

class SearchConnSuccess extends SearchConnectionState {
  final List<PureUser> users;
  final int currentPageNumber;
  final String query;
  final bool hasMore;

  const SearchConnSuccess({
    required this.users,
    required this.currentPageNumber,
    required this.query,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [users, hasMore];
}

class SearchConnFailure extends SearchConnectionState {
  const SearchConnFailure(this.message);
  final String message;
}

/// Events for search
abstract class SearchConnEvent extends Equatable {
  const SearchConnEvent();
}

class SearchConnTextChanged extends SearchConnEvent {
  const SearchConnTextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}
