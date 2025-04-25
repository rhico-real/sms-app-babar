import 'package:flutter/foundation.dart';
import 'package:sms_app/network/params/appointment/appointment_params.dart';
import 'package:sms_app/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';

/// A singleton class for managing blocs in background operations
@pragma('vm:entry-point')
class BackgroundBlocHelper {
  @pragma('vm:entry-point')
  static final BackgroundBlocHelper _instance = BackgroundBlocHelper._internal();
  
  @pragma('vm:entry-point')
  factory BackgroundBlocHelper() => _instance;

  @pragma('vm:entry-point')
  BackgroundBlocHelper._internal();
  
  // Static instances of blocs for background access
  static SmsBloc? _smsBloc;
  static AppointmentBloc? _appointmentBloc;
  
  // Register SMS bloc
  static void registerSmsBloc(SmsBloc bloc) {
    _smsBloc = bloc;
    if (kDebugMode) {
      print('SMS Bloc registered for background operations');
    }
  }
  
  // Register Appointment bloc
  static void registerAppointmentBloc(AppointmentBloc bloc) {
    _appointmentBloc = bloc;
    if (kDebugMode) {
      print('Appointment Bloc registered for background operations');
    }
  }
  
  // Safe method to add SMS events
  static void addSmsEvent(SmsEvent event) {
    try {
      if (_smsBloc != null) {
        _smsBloc!.add(event);
        if (kDebugMode) {
          print('Successfully added SMS event to bloc: ${event.runtimeType}');
        }
      } else {
        if (kDebugMode) {
          print('Warning: SMS bloc is not registered for background operations');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding SMS event in background: $e');
      }
    }
  }
  
  // Safe method to add Appointment events
  static void addAppointmentEvent(AppointmentEvent event) {
    try {
      if (_appointmentBloc != null) {
        _appointmentBloc!.add(event);
        if (kDebugMode) {
          print('Successfully added Appointment event to bloc: ${event.runtimeType}');
        }
      } else {
        if (kDebugMode) {
          print('Warning: Appointment bloc is not registered for background operations');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding Appointment event in background: $e');
      }
    }
  }
  
  // Notify of new SMS message (safe wrapper for RefreshMessages)
  static void notifyNewMessage() {
    addSmsEvent(RefreshMessages());
  }
  
  // Process pending messages
  static void processPendingMessages() {
    addSmsEvent(ProcessPendingMessages());
  }
  
  // Report error message format
  static void reportErrorFormat(String message) {
    addSmsEvent(ErrorCodeFormatMessage(message));
  }
  
  // Book appointment with safe background handling
  static void bookAppointment(AppointmentParams params, int messageId) {
    addAppointmentEvent(BookAppointment(params, messageId));
  }
}
