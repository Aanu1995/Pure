import 'package:bloc/bloc.dart';

class BottomBarBloc extends Bloc<int, int> {
  BottomBarBloc() : super(0) {
    on<int>((event, emit) {
      emit(event);
    });
  }
}
