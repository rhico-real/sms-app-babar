import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sms_app/core/background_bloc_helper.dart';
import 'package:sms_app/core/date_parser_helper.dart';
import 'package:sms_app/local_db/sms_db_helper.dart';
import 'package:sms_app/main.dart';
import 'package:sms_app/network/models/sms_message.dart';
import 'package:sms_app/network/params/appointment/appointment_params.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';

@pragma('vm:entry-point')
class SmsService {
  @pragma('vm:entry-point')
  static final SmsService _instance = SmsService._internal();
  
  @pragma('vm:entry-point')
  factory SmsService() => _instance;

  @pragma('vm:entry-point')
  SmsService._internal();

  // Initialize
  Future<void> initNotifications() async {
    // No initialization needed since we're not using flutter_local_notifications
    if (kDebugMode) {
      print('SMS service initialized.');
    }
  }

  // Holds a reference to the SMS bloc for updating UI when new messages arrive
  static SmsBloc? _smsBloc;
  
  // Register a bloc to receive updates
  static void registerBloc(SmsBloc bloc) {
    _smsBloc = bloc;
  }
  
  @pragma('vm:entry-point')
  DateTime? _parseCustomDate(String raw) {
    if (kDebugMode) {
      print('SmsService attempting to parse date: $raw');
    }
    
    // Use the new date parser helper that handles multiple formats
    return DateParserHelper.parseDate(raw);
  }

  @pragma('vm:entry-point')
  Future<void> processIncomingSms(String sender, String content) async {
    try {
      if (kDebugMode) {
        print("Processing SMS from $sender: $content");
      }
      
      final parts = content.split(' ');
      
      if (kDebugMode) {
        print("Message parts length: ${parts.length}");
      }

      // // First save the raw message regardless of format to ensure it's captured
      // final rawMessage = SmsMessage(
      //   sender: sender,
      //   content: content,
      //   status: 'Pending',
      //   timestamp: DateTime.now(),
      // );
      
      // final rawId = await SmsDbHelper.saveMessage(rawMessage);
      
      // if (kDebugMode) {
      //   print("Raw message saved with ID: $rawId");
      // }

      // Now try to process it
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
            // Using background-safe method
            BackgroundBlocHelper.reportErrorFormat("Invalid date format for sender $sender.");
            return;
          }

          final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          final reason = parts.sublist(dateIndex + 1).join(' ');

          // // Use the existing ID from the raw message
          // int id = rawId;
          
          // // Mark as processing first to prevent duplicate processing
          // bool canProcess = await SmsDbHelper.markMessageAsProcessing(id);
          
          // if (!canProcess) {
          //   if (kDebugMode) {
          //     print('Message ID $id is already being processed - skipping immediate processing');
          //   }
            
          //   // Still update the UI to show the message
          //   BackgroundBlocHelper.notifyNewMessage();
          //   _smsBloc?.add(RefreshMessages());
          //   return;
          // }
          
          final rawMessage = SmsMessage(
            sender: sender,
            content: content,
            status: 'Pending',
            timestamp: DateTime.now(),
          );
          
          final id = await SmsDbHelper.saveMessage(rawMessage);

          if (id > 0) {
            if (kDebugMode) {
              print('Message processed successfully with id: $id');
              print('Parsed Name: $fullName');
              print('Parsed Date: $formattedDate');
              print('Parsed Reason: $reason');
            }

            // Using background-safe methods
            BackgroundBlocHelper.notifyNewMessage();

            final appointmentParams = AppointmentParams(
              fullName: fullName,
              phoneNumber: sender,
              date: formattedDate,
              reason: reason,
            );

            // Process in the foreground if app is active, otherwise it will be handled when app reopens
            if (MainApp.navigatorKey.currentContext != null) {
              BackgroundBlocHelper.bookAppointment(appointmentParams, id);
            } else {
              // Just leave as Processing status to be handled when app reopens
              if (kDebugMode) {
                print('App context not available - message will be processed when app reopens');
              }
            }
            
            // Also update the static instance if available
            _smsBloc?.add(RefreshMessages());
          }
        } else {
          if (kDebugMode) {
            print('Date index error: dateIndex = $dateIndex');
          }
          BackgroundBlocHelper.reportErrorFormat("Invalid format for sender $sender.");
        }
      } else {
        if (kDebugMode) {
          print('Message format error: not an appointment message');
        }
        BackgroundBlocHelper.reportErrorFormat("Invalid format for sender $sender.");
      }
    } catch (e) {
      // Catch any errors in the entire processing chain
      if (kDebugMode) {
        print('Error in SMS processing: $e');
      }
      
      // Try to save a basic message at minimum to capture the SMS
      try {
        final fallbackMessage = SmsMessage(
          sender: sender,
          content: content,
          status: 'Error',
          timestamp: DateTime.now(),
        );
        await SmsDbHelper.saveMessage(fallbackMessage);
        
        // Try to notify UI if possible
        _smsBloc?.add(RefreshMessages());
        BackgroundBlocHelper.notifyNewMessage();
        
      } catch (innerError) {
        if (kDebugMode) {
          print('Critical error saving fallback message: $innerError');
        }
      }
    }
  }

}
