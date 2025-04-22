import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:sms_app/core/pending_message_processor.dart';
import 'package:sms_app/local_db/sms_db_helper.dart';
import 'package:sms_app/local_db/sms_service.dart';
import 'package:sms_app/network/models/sms_message.dart';

part 'sms_event.dart';
part 'sms_state.dart';

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  final SmsService _smsService = SmsService();

  SmsBloc() : super(SmsInitial()) {
    // Register this bloc with the SMS service to receive updates
    SmsService.registerBloc(this);
    on<LoadSmsMessages>(_onLoadSmsMessages);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<DeleteMessage>(_onDeleteMessage);
    on<RefreshMessages>(_onRefreshMessages);
    on<ReceiveNewMessage>(_onReceiveNewMessage);
    on<ErrorCodeFormatMessage>(_onErrorCodeFormatMessage);
    on<ProcessPendingMessages>(_onProcessPendingMessages);
  }

  Future<void> _onLoadSmsMessages(
    LoadSmsMessages event,
    Emitter<SmsState> emit,
  ) async {
    try {
      emit(SmsLoading());
      final messages = await SmsDbHelper.getAllMessages();
      emit(SmsLoaded(messages));
    } catch (e) {
      if (kDebugMode) {
        print("Error loading messages: $e");
      }
      emit(SmsError("Failed to load messages. Please try again."));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<SmsState> emit,
  ) async {
    try {
      if (state is SmsLoaded) {
        final currentState = state as SmsLoaded;
        await SmsDbHelper.markAsRead(event.messageId);
        
        // Update the message in the list
        final updatedMessages = currentState.messages.map((message) {
          if (message.id == event.messageId) {
            return SmsMessage(
              id: message.id,
              sender: message.sender,
              content: message.content,
              status: message.status,
              timestamp: message.timestamp,
              isRead: true,
            );
          }
          return message;
        }).toList();
        
        emit(SmsLoaded(updatedMessages));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error marking message as read: $e");
      }
      emit(SmsError("Failed to mark message as read. Please try again."));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<SmsState> emit,
  ) async {
    try {
      if (state is SmsLoaded) {
        final currentState = state as SmsLoaded;
        await SmsDbHelper.deleteMessage(event.messageId);
        
        // Remove the message from the list
        final updatedMessages = currentState.messages
            .where((message) => message.id != event.messageId)
            .toList();
        
        emit(SmsLoaded(updatedMessages));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting message: $e");
      }
      emit(SmsError("Failed to delete message. Please try again."));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<SmsState> emit,
  ) async {
    try {
      final messages = await SmsDbHelper.getAllMessages();
      emit(SmsLoaded(messages));
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing messages: $e");
      }
      emit(SmsError("Failed to refresh messages. Please try again."));
    }
  }

  Future<void> _onReceiveNewMessage(
    ReceiveNewMessage event,
    Emitter<SmsState> emit,
  ) async {
    try {
      await _smsService.processIncomingSms(event.sender, event.content);
      
      // Now refresh the messages list
      final messages = await SmsDbHelper.getAllMessages();
      emit(SmsLoaded(messages));
    } catch (e) {
      if (kDebugMode) {
        print("Error receiving new message: $e");
      }
      emit(SmsError("Failed to receive new message. Please try again."));
    }
  }

  Future<void> _onErrorCodeFormatMessage(ErrorCodeFormatMessage event, Emitter<SmsState> emit) async {
    emit(SmsCodeFormatError(event.message));
  }
  
  Future<void> _onProcessPendingMessages(
    ProcessPendingMessages event,
    Emitter<SmsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print("Processing pending messages via bloc event");
      }
      
      // Get the pending message processor
      final processor = PendingMessageProcessor();
      
      // Process pending messages
      await processor.processPendingMessages();
      
      // Then refresh the messages list
      final messages = await SmsDbHelper.getAllMessages();
      emit(SmsLoaded(messages));
    } catch (e) {
      if (kDebugMode) {
        print("Error processing pending messages: $e");
      }
      // Don't emit error state, just log it, to avoid disrupting UI
    }
  }
}
