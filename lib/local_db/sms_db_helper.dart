import 'package:flutter/foundation.dart';
import 'package:sms_app/local_db/db_helper.dart';
import 'package:sms_app/network/models/sms_message.dart';

@pragma('vm:entry-point')
class SmsDbHelper {
  // Save message to database
  @pragma('vm:entry-point')
  static Future<int> saveMessage(SmsMessage message) async {
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

  @pragma('vm:entry-point')
  static Future<bool> editMessage(int id, SmsMessage updatedMessage) async {
    try {
      final db = await SqliteDB.database();
      final count = await db.update(
        'sms_messages',
        updatedMessage.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating message: $e');
      }
      return false;
    }
  }

  // Get all messages
  @pragma('vm:entry-point')
  static Future<List<SmsMessage>> getAllMessages() async {
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
  @pragma('vm:entry-point')
  static Future<int> markAsRead(int id) async {
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

  // Update Message Status
  @pragma('vm:entry-point')
  static Future<int> updateMessageStatus(int id, String status) async {
    try {
      final db = await SqliteDB.database();
      return await db.update(
        'sms_messages',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating message status: $e');
      }
      return 0;
    }
  }
  
  // Mark message as processing (to prevent duplicate processing)
  @pragma('vm:entry-point')
  static Future<bool> markMessageAsProcessing(int id) async {
    try {
      final db = await SqliteDB.database();
      
      // First check if the message is already being processed or processed
      final List<Map<String, dynamic>> checkResult = await db.query(
        'sms_messages',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (checkResult.isEmpty) {
        return false;
      }
      
      final currentStatus = checkResult.first['status'] as String;
      
      // Only allow processing if status is 'Pending' or 'Processing'
      // Allow 'Processing' too so it can continue if app was closed during processing
      if (currentStatus != 'Pending' && currentStatus != 'Processing') {
        if (kDebugMode) {
          print('Message $id has status: $currentStatus - skipping');
        }
        return false;
      }
      
      // Update the status to "Processing"
      final result = await db.update(
        'sms_messages',
        {'status': 'Processing'},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return result > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as processing: $e');
      }
      return false;
    }
  }

  // Delete message
  @pragma('vm:entry-point')
  static Future<int> deleteMessage(int id) async {
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
}