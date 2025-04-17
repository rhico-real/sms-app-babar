part of 'sms_bloc.dart';

abstract class SmsState extends Equatable {
  const SmsState();
  
  @override
  List<Object> get props => [];
}

class SmsInitial extends SmsState {}

class SmsLoading extends SmsState {}

class SmsLoaded extends SmsState {
  final List<SmsMessage> messages;

  const SmsLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class SmsError extends SmsState {
  final String message;

  const SmsError(this.message);

  @override
  List<Object> get props => [message];
}
