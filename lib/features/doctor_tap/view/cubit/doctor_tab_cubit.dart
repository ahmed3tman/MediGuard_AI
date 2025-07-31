import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_tab_state.dart';

class DoctorTabCubit extends Cubit<DoctorTabState> {
  DoctorTabCubit() : super(DoctorTabInitial());

  // يمكنك إضافة دوال التحكم هنا لاحقاً
  void refreshData() {
    emit(DoctorTabLoading());
    // بعد جلب البيانات:
    // emit(DoctorTabLoaded(...));
  }
}
