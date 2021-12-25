import 'package:bloc/bloc.dart';

class BottomBarBloc extends Cubit<int> {
  BottomBarBloc() : super(0);

  void onBottomItemPressed(int itemIndex) => emit(itemIndex);

  void reset() => emit(0);
}
