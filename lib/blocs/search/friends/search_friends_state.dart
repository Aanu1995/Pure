import 'package:equatable/equatable.dart';

import '../../../model/connection_model.dart';

/// States for Search
class SearchFriendState extends Equatable {
  const SearchFriendState();

  @override
  List<Object?> get props => [];
}

class SearchFriendEmpty extends SearchFriendState {}

class SearchFriendLoading extends SearchFriendState {}

class SearchFriendSuccess extends SearchFriendState {
  final List<Connector> friends;
  final String query;

  const SearchFriendSuccess({required this.friends, this.query = ""});

  @override
  List<Object?> get props => [friends, query];
}

class SearchFriendFailure extends SearchFriendState {
  const SearchFriendFailure(this.message);
  final String message;
}

/// Events for search
abstract class SearchFriendEvent extends Equatable {
  const SearchFriendEvent();
}

class SearchFriendTextChanged extends SearchFriendEvent {
  const SearchFriendTextChanged({
    required this.text,
    required this.currentUserId,
    required this.friendIds,
  });

  final String text;
  final String currentUserId;
  final List<String> friendIds;

  @override
  List<Object> get props => [text, currentUserId, friendIds];
}

class LoadAvailableFriends extends SearchFriendEvent {
  const LoadAvailableFriends({required this.friends});

  final List<Connector> friends;

  @override
  List<Object> get props => [friends];
}

class DeleteFriend extends SearchFriendEvent {
  const DeleteFriend({required this.index});

  final int index;

  @override
  List<Object> get props => [index];
}

class AddFriend extends SearchFriendEvent {
  const AddFriend({required this.index, required this.friend});

  final int index;
  final Connector friend;

  @override
  List<Object> get props => [index, friend];
}
