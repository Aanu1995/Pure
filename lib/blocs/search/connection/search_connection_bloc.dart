import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/pure_user_model.dart';
import '../../../services/search_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/request_messages.dart';
import '../search_username.dart';
import 'search_connection_state.dart';

class SearchConnBloc extends Bloc<SearchConnEvent, SearchConnectionState> {
  final SearchService searchService;
  SearchConnBloc(this.searchService) : super(SearchConnEmpty()) {
    on<SearchConnTextChanged>(_onTextChanged, transformer: debounce(duration));
  }

  Future<void> _onTextChanged(
    SearchConnTextChanged event,
    Emitter<SearchConnectionState> emit,
  ) async {
    final query = event.text;

    emit(SearchConnLoading());

    try {
      final result = await searchService.searchForUser(query, hitsPerPage: 8);
      emit(
        SearchConnSuccess(users: result, currentPageNumber: 0, query: query),
      );
    } on NetworkException catch (e) {
      emit(SearchConnFailure(e.message!));
    } on ServerException catch (e) {
      emit(SearchConnFailure(e.message!));
    } catch (_) {
      emit(SearchConnFailure(ErrorMessages.generalMessage));
    }
  }
}

class SeeAllUsersCubit extends Cubit<SearchConnectionState> {
  final SearchService searchService;
  SeeAllUsersCubit(this.searchService) : super(SearchConnEmpty());

  Future<void> searchUsers(String query) async {
    emit(SearchConnLoading());

    try {
      final result = await searchService.searchForUser(query);
      result.removeWhere((user) => user.id == CurrentUser.currentUserId);

      emit(
        SearchConnSuccess(
          users: result,
          currentPageNumber: 0,
          query: query,
          hasMore: !result.isEmpty,
        ),
      );
    } on NetworkException catch (e) {
      emit(SearchConnFailure(e.message!));
    } on ServerException catch (e) {
      emit(SearchConnFailure(e.message!));
    } catch (_) {
      emit(SearchConnFailure(ErrorMessages.generalMessage));
    }
  }

  void updateConnections(List<PureUser> users, String query, int pageNumber,
      {bool hasMore = true}) {
    final newUserList = users.toList();
    newUserList.removeWhere((user) => user.id == CurrentUser.currentUserId);
    emit(
      SearchConnSuccess(
        users: newUserList,
        currentPageNumber: pageNumber,
        query: query,
        hasMore: hasMore,
      ),
    );
  }
}

class LoadMoreUsersCubit extends Cubit<SearchConnectionState> {
  final SearchService searchService;
  LoadMoreUsersCubit(this.searchService) : super(SearchConnEmpty());

  Future<void> loadMoreUsers(
      List<PureUser> users, String query, int pageNumber) async {
    emit(SearchConnLoading());

    try {
      final result =
          await searchService.searchForUser(query, pageNumber: pageNumber);
      final newList = [...users.toList(), ...result];

      emit(
        SearchConnSuccess(
          users: newList,
          currentPageNumber: pageNumber,
          query: query,
          hasMore: !result.isEmpty,
        ),
      );
    } on NetworkException catch (e) {
      emit(SearchConnFailure(e.message!));
    } on ServerException catch (e) {
      emit(SearchConnFailure(e.message!));
    } catch (_) {
      emit(SearchConnFailure(ErrorMessages.generalMessage));
    }
  }
}
