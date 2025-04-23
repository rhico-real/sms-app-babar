import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sms_app/core/background_bloc_helper.dart';
import 'package:sms_app/core/date_parser_helper.dart';
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
      
      // Get all messages with "Pending" or "Processing" status
      final messages = await SmsDbHelper.getAllMessages();
      final pendingMessages = messages.where(
        (msg) => msg.status == 'Pending' || msg.status == 'Processing'
      ).toList();
      
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
        await processMessage(message);
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
    if (kDebugMode) {
      print('PendingMessageProcessor attempting to parse date: $raw');
    }
    
    // Use the new date parser helper that handles multiple formats
    return DateParserHelper.parseDate(raw);
  }
  
  Future<void> processMessage(SmsMessage message) async {
    try {
      if (message.id == null) {
        if (kDebugMode) {
          print('Message ID is null, cannot process');
        }
        return;
      }
      
      // Try to mark the message as processing - if this returns false,
      // it means the message is already being processed or is not in Pending state
      bool canProcess = await SmsDbHelper.markMessageAsProcessing(message.id!);
      
      if (!canProcess) {
        if (kDebugMode) {
          print('Message ID ${message.id} is already processed or being processed - skipping');
        }
        return;
      }
      
      if (kDebugMode) {
        print('Processing pending message ID: ${message.id}, content: ${message.content}');
      }
      
      
      await validateAndProcessMessage(message);
      
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

  Future<void> validateAndProcessMessage(SmsMessage message) async {
    final content = message.content;
      final parts = content.split(' ');
    if (parts.length >= 3 && parts[0].toLowerCase() == 'appointment') {
        // Match both text and numeric date formats
        final dateRegex = RegExp(
          r'^([A-Za-z]+[0-9]{1,2}[0-9]{4}$)|' +  // April22025, apr22025
          r'^([0-9]{2}[0-9]{2}[0-9]{4}$)|' +     // 04022025
          r'^([0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$)'  // 04/02/2025
        );
        
        int dateIndex = parts.indexWhere((part) => dateRegex.hasMatch(part));
        
        if (kDebugMode) {
          print('Date pattern search result: dateIndex = $dateIndex, part: ${dateIndex >= 0 ? parts[dateIndex] : "not found"}');
        }
        
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
  }
}