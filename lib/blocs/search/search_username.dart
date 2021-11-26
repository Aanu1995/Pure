import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../services/search_service.dart';

const duration = const Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService searchService;
  SearchBloc(this.searchService) : super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(duration));
  }

  Future<void> _onTextChanged(
    TextChanged event,
    Emitter<SearchState> emit,
  ) async {
    final username = event.text;

    if (username.isEmpty) return emit(SearchStateEmpty());

    emit(SearchStateLoading());

    bool isAvailable = await searchService.searchUsername(username);
    emit(SearchSuccess(isAvailable, username));
  }
}

class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// States for Search

class SearchStateEmpty extends SearchState {}

class SearchStateLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final bool isAvailable;
  final String username;

  const SearchSuccess(this.isAvailable, this.username);

  @override
  List<Object?> get props => [isAvailable];
}

/// Events for search
abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class TextChanged extends SearchEvent {
  const TextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}
