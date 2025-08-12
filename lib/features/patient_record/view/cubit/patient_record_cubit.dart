import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_record_state.dart';

class PatientRecordCubit extends Cubit<PatientRecordState> {
  PatientRecordCubit() : super(PatientRecordInitial());

  // يمكنك إضافة دوال التحكم هنا لاحقاً
  void refreshData() {
    emit(PatientRecordLoading());
    // بعد جلب البيانات:
    // emit(PatientRecordLoaded(...));
  }
}
