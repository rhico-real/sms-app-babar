part of 'sms_bloc.dart';

abstract class SmsEvent extends Equatable {
  const SmsEvent();

  @override
  List<Object> get props => [];
}

class LoadSmsMessages extends SmsEvent {}

class MarkMessageAsRead extends SmsEvent {
  final int messageId;

  const MarkMessageAsRead(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class DeleteMessage extends SmsEvent {
  final int messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class RefreshMessages extends SmsEvent {}

class ReceiveNewMessage extends SmsEvent {
  final String sender;
  final String content;

  const ReceiveNewMessage({
    required this.sender,
    required this.content,
  });

  @override
  List<Object> get props => [sender, content];
}

class ErrorCodeFormatMessage extends SmsEvent {
  final String message;

  const ErrorCodeFormatMessage(this.message);

  @override
  List<Object> get props => [message];
}

class ProcessPendingMessages extends SmsEvent {}