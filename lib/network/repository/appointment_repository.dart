import 'package:sms_app/core/data_state.dart';
import 'package:sms_app/core/repository_helper.dart';
import 'package:sms_app/network/models/appointment/appointment_model.dart';
import 'package:sms_app/network/params/appointment/appointment_params.dart';

class AppointmentRepository {
  // =================================================================
  //                         POST: Make Appointment
  // =================================================================
  Future<DataState> addAppointment({required AppointmentParams appointmentParams}) async {
    final payload = {'full_name': appointmentParams.fullName, 'phone_number': appointmentParams.phoneNumber, 'date': appointmentParams.date, 'reason': appointmentParams.reason};

    DataState? data = await RepositoryHelper().post(payload: payload, endpoint: 'add_appointment', fromJson: (json) => AppointmentModel.fromJson(json));
    return data;
  }
}