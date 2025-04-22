part of 'appointment_bloc.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();
  
  @override
  List<Object> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class LoadingAppointment extends AppointmentState {}

class SuccessAppointment extends AppointmentState {
  final String message;

  const SuccessAppointment(this.message);

  @override
  List<Object> get props => [message];
}

class ErrorAppointment extends AppointmentState {
  final String message;

  const ErrorAppointment(this.message);

  @override
  List<Object> get props => [message];
}
