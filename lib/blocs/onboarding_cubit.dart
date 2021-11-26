import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/local_storage.dart';
import '../utils/global_utils.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit(this.localStorage) : super(OnBoardingInitial());
  final LocalStorage localStorage;

  Future<void> isUserBoarded() async {
    final key = GlobalUtils.onBoardingSharedPrefKey;
    final isUserBoarded = await localStorage.getBoolData(key) ?? false;
    if (isUserBoarded) {
      emit(OnBoarded());
    } else {
      emit(NotBoarded());
    }
  }

  void setOnBoardingStatus() {
    localStorage.saveBoolData(GlobalUtils.onBoardingSharedPrefKey, true);
    emit(OnBoarded());
  }
}

abstract class OnBoardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnBoardingInitial extends OnBoardingState {}

class OnBoarded extends OnBoardingState {}

class NotBoarded extends OnBoardingState {}
