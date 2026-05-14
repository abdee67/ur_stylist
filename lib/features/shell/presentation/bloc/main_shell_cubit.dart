import 'package:flutter_bloc/flutter_bloc.dart';

class MainShellCubit extends Cubit<int> {
  MainShellCubit() : super(0);

  void setTab(int index) => emit(index);
}
