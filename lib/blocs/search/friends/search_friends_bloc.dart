import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/search_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/request_messages.dart';
import '../search_username.dart';
import 'search_friends_state.dart';

class SearchFriendBloc extends Bloc<SearchFriendEvent, SearchFriendState> {
  final SearchService searchService;
  SearchFriendBloc(this.searchService) : super(SearchFriendEmpty()) {
    on<SearchFriendTextChanged>(_onTextChanged,
        transformer: debounce(duration));
    on<LoadAvailableFriends>(_loadCurrentConnectiors,
        transformer: debounce(duration));
    on<AddFriend>(_addFriend, transformer: debounce(duration));
    on<DeleteFriend>(_deletFriend, transformer: debounce(duration));
  }

  // load all current connectors
  Future<void> _loadCurrentConnectiors(
      LoadAvailableFriends event, Emitter<SearchFriendState> emit) async {
    emit(SearchFriendSuccess(friends: event.friends));
  }

  Future<void> _onTextChanged(
      SearchFriendTextChanged event, Emitter<SearchFriendState> emit) async {
    try {
      if (event.text.isNotEmpty) {
        final result = await searchService.searchForFriends(
          event.text,
          event.currentUserId,
          event.friendIds,
        );
        emit(SearchFriendSuccess(friends: result, query: event.text));
      } else {
        emit(SearchFriendSuccess(friends: [], query: event.text));
      }
    } on NetworkException catch (e) {
      emit(SearchFriendFailure(e.message!));
    } on ServerException catch (e) {
      emit(SearchFriendFailure(e.message!));
    } catch (_) {
      emit(SearchFriendFailure(ErrorMessages.generalMessage));
    }
  }

  void _deletFriend(DeleteFriend event, Emitter<SearchFriendState> emit) {
    final currentState = state;
    if (currentState is SearchFriendSuccess) {
      final friendList = currentState.friends.toList();

      friendList.removeAt(event.index);
      emit(SearchFriendSuccess(friends: friendList, query: currentState.query));
    }
  }

  void _addFriend(AddFriend event, Emitter<SearchFriendState> emit) {
    final currentState = state;
    if (currentState is SearchFriendSuccess) {
      final friendList = currentState.friends.toList();
      // remove the invitee from the list
      friendList.insert(event.index, event.friend);

      emit(SearchFriendSuccess(friends: friendList, query: currentState.query));
    }
  }
}
