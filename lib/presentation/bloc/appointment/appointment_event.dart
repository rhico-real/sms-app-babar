part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class BookAppointment extends AppointmentEvent {
  final AppointmentParams appointmentParams;
  final int localMessageId;
  const BookAppointment(this.appointmentParams, this.localMessageId);

  @override
  List<Object> get props => [appointmentParams];
}