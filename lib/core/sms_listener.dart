import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sms_app/local_db/sms_service.dart';
import 'package:another_telephony/telephony.dart';
import 'package:sms_app/core/background_bloc_helper.dart';

/// A service that listens for incoming SMS messages using the another_telephony package.
@pragma('vm:entry-point')
class SmsListener {
  @pragma('vm:entry-point')
  static final SmsListener _instance = SmsListener._internal();
  
  @pragma('vm:entry-point')
  factory SmsListener() => _instance;

  @pragma('vm:entry-point')
  SmsListener._internal();

  final Telephony _telephony = Telephony.instance;
  bool _isListening = false;
  SmsService _smsService = SmsService();
  final MethodChannel _channel = const MethodChannel('com.babar.sms_app/sms');

  /// Background message handler for SMS
  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    try {
      // This method is called when a message is received while the app is in the background
      if (kDebugMode) {
        print("Background message received: ${message.body}");
      }
      
      // Process the message in the background
      final smsService = SmsService();
      final sender = message.address ?? "Unknown";
      final content = message.body ?? "No content";
      
      // Process the incoming SMS using our improved service
      await smsService.processIncomingSms(sender, content);
      
      if (kDebugMode) {
        print("Background message processed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in background message handler: $e");
      }
      
      // Try a fallback approach to at least save the message
      try {
        final sender = message.address ?? "Unknown";
        final content = message.body ?? "No content";
        
        // Create a basic SMS service and attempt minimal processing
        final fallbackService = SmsService();
        await fallbackService.processIncomingSms(sender, content);
        
        if (kDebugMode) {
          print("Fallback processing completed for background message");
        }
      } catch (innerError) {
        if (kDebugMode) {
          print("Critical error in background message handler: $innerError");
        }
      }
    }
  }

  /// Start listening for incoming SMS messages with both foreground and background support
  Future<void> startListeningInForegroundMode() async {
    if (_isListening) return;
    
    if (kDebugMode) {
      print('Started listening for SMS messages...');
    }
    
    // Request SMS permissions
    bool? permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
    
    if (permissionsGranted == false) {
      if (kDebugMode) {
        print('SMS Permissions not granted');
      }
      return;
    }
    
    _isListening = true;
    
    try {
      // Listen for incoming SMS with both foreground and background support
      _telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Process new message in foreground
          _handleIncomingSms(message);
        },
        onBackgroundMessage: backgroundMessageHandler,
        listenInBackground: true,
      );
      
      // Also set up the foreground service to ensure app stays alive
      _setupForegroundService();
      
      if (kDebugMode) {
        print('SMS listening setup successful');
      }
    } catch (e) {
      _isListening = false;
      if (kDebugMode) {
        print('Error setting up SMS listening: $e');
      }
    }
  }

  /// For compatibility, keep the original method but use the new mode
  Future<void> startListening() async {
    return startListeningInForegroundMode();
  }

  /// Set up foreground service for better reliability
  Future<void> _setupForegroundService() async {
    try {
      // Start foreground service on the platform side
      await _channel.invokeMethod('setupPeriodicChecking');
      if (kDebugMode) {
        print('Foreground service setup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Foreground service setup note: $e (this may be expected on first run)');
      }
    }
  }

  /// Handle an incoming SMS message
  void _handleIncomingSms(SmsMessage message) {
    if (!_isListening) return;
    
    final sender = message.address ?? "Unknown";
    final content = message.body ?? "No content";
    
    try {
      // Process the message directly with SMS service
      _smsService.processIncomingSms(sender, content);
      
      if (kDebugMode) {
        print('Received SMS from $sender: $content');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing incoming SMS: $e');
      }
    }
  }

  /// Check if the service is currently listening for messages
  bool get isListening => _isListening;
}
