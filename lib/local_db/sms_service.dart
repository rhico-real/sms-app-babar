import 'package:flutter/foundation.dart';
import 'package:sms_app/local_db/db_helper.dart';
import 'package:sms_app/network/models/sms_message.dart';
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

  // Save message to database
  Future<int> saveMessage(SmsMessage message) async {
    try {
      final db = await SqliteDB.database();
      final id = await db.insert('sms_messages', message.toMap());
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving message: $e');
      }
      return -1;
    }
  }

  // Get all messages
  Future<List<SmsMessage>> getAllMessages() async {
    try {
      final db = await SqliteDB.database();
      final List<Map<String, dynamic>> maps = await db.query(
        'sms_messages',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return SmsMessage.fromMap(maps[i]);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting messages: $e');
      }
      return [];
    }
  }

  // Mark message as read
  Future<int> markAsRead(int id) async {
    try {
      final db = await SqliteDB.database();
      return await db.update(
        'sms_messages',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as read: $e');
      }
      return 0;
    }
  }

  // Delete message
  Future<int> deleteMessage(int id) async {
    try {
      final db = await SqliteDB.database();
      return await db.delete(
        'sms_messages',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
      return 0;
    }
  }

  // Holds a reference to the SMS bloc for updating UI when new messages arrive
  static SmsBloc? _smsBloc;
  
  // Register a bloc to receive updates
  static void registerBloc(SmsBloc bloc) {
    _smsBloc = bloc;
  }
  
  // Process an incoming SMS
  @pragma('vm:entry-point')
  Future<void> processIncomingSms(String sender, String content) async {
    final message = SmsMessage(
      sender: sender,
      content: content,
      status: 'Pending',
      timestamp: DateTime.now(),
    );
    
    final id = await saveMessage(message);
    if (id > 0) {
      if (kDebugMode) {
        print('Message saved with id: $id');
        print('Received new message from: $sender');
      }
      
      // Notify the SMS bloc if it's available
      if (_smsBloc != null) {
        try {
          _smsBloc!.add(RefreshMessages());
        } catch (e) {
          if (kDebugMode) {
            print('Error refreshing messages: $e');
          }
        }
      }
    }
  }
}
