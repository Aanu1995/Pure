import 'package:bloc/bloc.dart';

class BottomBarCubit extends Cubit<int> {
  BottomBarCubit() : super(0);

  void onBottomItemPressed(int itemIndex) => emit(itemIndex);

  void reset() => emit(0);
}
