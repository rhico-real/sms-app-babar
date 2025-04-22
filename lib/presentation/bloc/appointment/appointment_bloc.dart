import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';
import 'package:sms_app/core/background_bloc_helper.dart';
import 'package:sms_app/core/data_state.dart';
import 'package:sms_app/local_db/sms_db_helper.dart';
import 'package:sms_app/network/params/appointment/appointment_params.dart';
import 'package:sms_app/network/repository/appointment_repository.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc() : super(AppointmentInitial()) {
    on<BookAppointment>(_onBookAppointment);
  }

  Future<void> _onBookAppointment(
    BookAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(LoadingAppointment());
      
      if (kDebugMode) {
        print("Booking appointment for: ${event.appointmentParams.fullName} on ${event.appointmentParams.date}");
      }
      
      final data = await AppointmentRepository().addAppointment(appointmentParams: event.appointmentParams);

      if(data is DataSuccess){
        await SmsDbHelper.updateMessageStatus(event.localMessageId, "Booked");
        
        // Update UI using background-safe method
        BackgroundBlocHelper.notifyNewMessage();
        
        if (kDebugMode) {
          print("Successfully booked appointment for message ID: ${event.localMessageId}");
        }

        emit(SuccessAppointment("Successfully booked Appointment!"));
      } else {
        if (kDebugMode) {
          print("Failed to book appointment: ${(data as DataFailed).error}");
        }
        
        await SmsDbHelper.updateMessageStatus(event.localMessageId, "Failed");
        BackgroundBlocHelper.notifyNewMessage();
        
        emit(ErrorAppointment("Error booking Appointment!"));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception booking appointment: $e");
      }
      
      await SmsDbHelper.updateMessageStatus(event.localMessageId, "Failed");
      BackgroundBlocHelper.notifyNewMessage();
      
      emit(ErrorAppointment("Error booking Appointment!"));
    }
  }
}
