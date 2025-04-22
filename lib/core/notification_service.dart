import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Notification channel ID and name
  static const String _foregroundChannelId = 'sms_listener_foreground';
  static const String _foregroundChannelName = 'SMS Listener Foreground Service';
  static const String _foregroundChannelDescription = 'Shows a notification when the app is listening for SMS messages';
  
  // This is needed for the another_telephony package to work properly
  static const String _backgroundChannelId = 'sms_listener_background';
  static const String _backgroundChannelName = 'SMS Listener Background Service';
  static const String _backgroundChannelDescription = 'Background service for SMS listening';
  
  // Notification IDs - we'll use a single ID to prevent duplicate notifications
  static const int _listeningNotificationId = 1001;
  
  /// Initialize notification settings
  Future<void> initialize() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // General initialization settings
      const InitializationSettings initializationSettings = 
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Initialize the plugin
      await _notificationsPlugin.initialize(
        initializationSettings,
      );
      
      // Request notification permission for Android 13+ (API level 33+)
      await _requestNotificationPermissions();
      
      // Create the notification channel with higher importance
      await _createForegroundChannel();
      
      if (kDebugMode) {
        print('Notification service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }
  
  /// Request notification permissions for Android 13+
  Future<void> _requestNotificationPermissions() async {
    try {
      // For Android, we need to check the API level at runtime and request permissions accordingly
      // With flutter_local_notifications 19.1.0, we should use requestPermission
      
      // This method will do nothing on Android versions below 13 (Tiramisu/API level 33)
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // Also request precise alarms permission if needed
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
          
      if (kDebugMode) {
        print('Notification permissions requested');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
    }
  }
  
  /// Create the notification channels with proper settings
  Future<void> _createForegroundChannel() async {
    try {
      // Create a channel with higher importance for the foreground service
      const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
        _foregroundChannelId,
        _foregroundChannelName,
        description: _foregroundChannelDescription,
        importance: Importance.high,
        enableVibration: false,
        showBadge: false,
      );
      
      // Create a channel for background service
      const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
        _backgroundChannelId,
        _backgroundChannelName,
        description: _backgroundChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        showBadge: true,
      );
      
      // Create the Android channels
      final notificationPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      await notificationPlugin?.createNotificationChannel(foregroundChannel);
      await notificationPlugin?.createNotificationChannel(backgroundChannel);
          
      if (kDebugMode) {
        print('Notification channels created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification channels: $e');
      }
    }
  }
  
  /// Show a persistent notification that the app is listening for SMS messages
  Future<void> showListeningNotification() async {
    try {
      // Android-specific notification details for foreground service
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        _foregroundChannelId,
        _foregroundChannelName,
        channelDescription: _foregroundChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        // Make notification persistent and undismissable
        ongoing: true,
        autoCancel: false,
        // These settings make the notification part of a foreground service
        playSound: false,
        enableLights: false,
        enableVibration: false,
        // Use the app icon - most reliable approach
        icon: 'mipmap/launcher_icon',
        category: AndroidNotificationCategory.service,
        visibility: NotificationVisibility.public,
        color: const Color.fromARGB(255, 33, 150, 243), // Blue color
        // This is important to prevent dismissal
        onlyAlertOnce: true,
        
        // No actions to prevent accidental dismissal
        actions: [],
      );
      
      // iOS specific notification details
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          );
      
      // General notification details
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      
      // Cancel any existing notifications first to prevent duplicates
      await _notificationsPlugin.cancel(_listeningNotificationId);
      
      // Show the notification as a foreground service notification
      await _notificationsPlugin.show(
        _listeningNotificationId,
        'BABAR SMS Listener',
        'Listening for appointment SMS messages',
        notificationDetails,
      );
      
      if (kDebugMode) {
        print('Listening notification shown');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing listening notification: $e');
      }
    }
  }
  
  /// Cancel all notifications to ensure we start fresh
  Future<void> cancelListeningNotification() async {
    try {
      // Cancel our specific notification
      await _notificationsPlugin.cancel(_listeningNotificationId);
      
      // Also try to cancel any other notifications that might be showing
      await _notificationsPlugin.cancelAll();
      
      if (kDebugMode) {
        print('All notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling notifications: $e');
      }
    }
  }
}
