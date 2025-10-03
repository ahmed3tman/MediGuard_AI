import 'package:flutter_bloc/flutter_bloc.dart';
import '../../edit_patient_info/model/patient_info_model.dart';
import '../services/add_device_service.dart';
import 'add_device_state.dart';

class AddDeviceCubit extends Cubit<AddDeviceState> {
  AddDeviceCubit() : super(const AddDeviceInitial());

  /// Adds the device and saves patient metadata. Emits loading/success/error.
  Future<void> addDeviceAndPatient({
    required dynamic context,
    required PatientInfo patientInfo,
  }) async {
    emit(const AddDeviceLoading());
    try {
      // Call the service which will also use PatientInfoCubit internally
      await AddDeviceService.addDeviceAndSavePatient(context, patientInfo);
      emit(AddDeviceSuccess(patientInfo));
    } catch (e) {
      emit(AddDeviceError(e.toString()));
      rethrow;
    }
  }
}
