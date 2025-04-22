import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sms_app/core/background_bloc_helper.dart';
import 'package:sms_app/local_db/sms_db_helper.dart';
import 'package:sms_app/network/models/sms_message.dart';
import 'package:sms_app/network/params/appointment/appointment_params.dart';

class PendingMessageProcessor {
  static final PendingMessageProcessor _instance = PendingMessageProcessor._internal();
  
  factory PendingMessageProcessor() => _instance;
  
  PendingMessageProcessor._internal();
  
  Future<void> processPendingMessages() async {
    try {
      if (kDebugMode) {
        print('Checking for pending messages to process...');
      }
      
      // Get all messages with "Pending" status
      final messages = await SmsDbHelper.getAllMessages();
      final pendingMessages = messages.where((msg) => msg.status == 'Pending').toList();
      
      if (pendingMessages.isEmpty) {
        if (kDebugMode) {
          print('No pending messages found.');
        }
        return;
      }
      
      if (kDebugMode) {
        print('Found ${pendingMessages.length} pending messages to process.');
      }
      
      // Process each pending message
      for (var message in pendingMessages) {
        await _processMessage(message);
      }
      
      // Refresh the UI after processing
      BackgroundBlocHelper.notifyNewMessage();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error processing pending messages: $e');
      }
    }
  }
  
  DateTime? _parseCustomDate(String raw) {
    final match = RegExp(r'^([A-Za-z]+)(\d{1,2})(\d{4})$').firstMatch(raw);
    if (match != null) {
      final month = match.group(1)!;
      final day = match.group(2)!;
      final year = match.group(3)!;
      final spaced = '$month $day $year';

      for (final format in ['MMMM d yyyy', 'MMM d yyyy']) {
        try {
          return DateFormat(format).parseStrict(spaced);
        } catch (_) {}
      }
    }
    return null;
  }
  
  Future<void> _processMessage(SmsMessage message) async {
    try {
      if (kDebugMode) {
        print('Processing pending message ID: ${message.id}, content: ${message.content}');
      }
      
      final content = message.content;
      final parts = content.split(' ');
      
      if (parts.length >= 3 && parts[0].toLowerCase() == 'appointment') {
        final dateRegex = RegExp(r'^[A-Za-z]+[0-9]{1,2}[0-9]{4}$');
        int dateIndex = parts.indexWhere((part) => dateRegex.hasMatch(part));
        
        if (dateIndex > 1) {
          final rawFullName = parts.sublist(1, dateIndex).join('');
          final fullName = rawFullName.replaceAllMapped(
            RegExp(r'(?<!^)([A-Z])'),
            (match) => ' ${match.group(1)}',
          );
          
          final dateString = parts[dateIndex];
          final parsedDate = _parseCustomDate(dateString);
          
          if (parsedDate == null) {
            if (kDebugMode) {
              print('Error parsing date: $dateString');
            }
            await SmsDbHelper.updateMessageStatus(message.id!, "Failed");
            BackgroundBlocHelper.reportErrorFormat("Invalid date format for sender ${message.sender}.");
            return;
          }
          
          final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          final reason = parts.sublist(dateIndex + 1).join(' ');
          
          if (kDebugMode) {
            print('Processed pending message:');
            print('Name: $fullName');
            print('Date: $formattedDate');
            print('Reason: $reason');
          }
          
          final appointmentParams = AppointmentParams(
            fullName: fullName,
            phoneNumber: message.sender,
            date: formattedDate,
            reason: reason,
          );
          
          // Book the appointment
          BackgroundBlocHelper.bookAppointment(appointmentParams, message.id!);
          
        } else {
          if (kDebugMode) {
            print('Invalid message format: date index error');
          }
          await SmsDbHelper.updateMessageStatus(message.id!, "Failed");
          BackgroundBlocHelper.reportErrorFormat("Invalid format for sender ${message.sender}.");
        }
      } else {
        if (kDebugMode) {
          print('Invalid message format: not an appointment message');
        }
        await SmsDbHelper.updateMessageStatus(message.id!, "Failed");
        BackgroundBlocHelper.reportErrorFormat("Invalid format for sender ${message.sender}.");
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error processing pending message: $e');
      }
      try {
        await SmsDbHelper.updateMessageStatus(message.id!, "Failed");
      } catch (updateError) {
        if (kDebugMode) {
          print('Error updating message status: $updateError');
        }
      }
    }
  }
}