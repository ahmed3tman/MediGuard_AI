import '../../edit_patient_info/model/patient_info_model.dart';

abstract class AddDeviceState {
  const AddDeviceState();
}

class AddDeviceInitial extends AddDeviceState {
  const AddDeviceInitial();
}

class AddDeviceLoading extends AddDeviceState {
  const AddDeviceLoading();
}

class AddDeviceSuccess extends AddDeviceState {
  final PatientInfo patientInfo;
  const AddDeviceSuccess(this.patientInfo);
}

class AddDeviceError extends AddDeviceState {
  final String message;
  const AddDeviceError(this.message);
}
