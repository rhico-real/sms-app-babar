package com.basroot.sms.app

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.util.Log
import androidx.core.app.NotificationCompat
import com.basroot.sms.app.service.SmsListenerService
import android.app.AlarmManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.babar.sms_app/sms"
    private val TAG = "SMSListener"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setupPeriodicChecking" -> {
                    // Stop any existing service first to prevent duplicates
                    stopBackgroundService()
                    // Then start a new service
                    setupBackgroundService()
                    result.success(true)
                }
                "stopPeriodicChecking" -> {
                    stopBackgroundService()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun stopBackgroundService() {
        try {
            val intent = Intent(this, SmsListenerService::class.java)
            stopService(intent)
            Log.d(TAG, "Background service stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping background service: ${e.message}")
        }
    }
    
    private fun setupBackgroundService() {
        try {
            Log.d(TAG, "Setting up background service")
            
            // Request alarm permissions for Android 12+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                if (!alarmManager.canScheduleExactAlarms()) {
                    // Request permission via intent
                    val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                    startActivity(intent)
                }
            }
            
            // Start our custom foreground service
            val serviceIntent = Intent(this, SmsListenerService::class.java)
            
            // For Android 8.0+, start the service as a foreground service
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
            
            // Set up an alarm to keep our service alive
            setRepeatingAlarm()
            
            Log.d(TAG, "Background service started successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error setting up background service: ${e.message}")
        }
    }
    
    private fun setRepeatingAlarm() {
        try {
            // Set up an alarm to restart our service periodically
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, SmsListenerService::class.java)
            val pendingIntent = PendingIntent.getService(
                this,
                1001,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Schedule the alarm to repeat every 15 minutes
            val intervalMillis = 15 * 60 * 1000L // 15 minutes
            val startTime = System.currentTimeMillis() + intervalMillis
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Use setExactAndAllowWhileIdle for newer Android versions
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    startTime,
                    pendingIntent
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                // Use setExact for Android KitKat and above
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    startTime,
                    pendingIntent
                )
            } else {
                // Use set for older Android versions
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    startTime,
                    pendingIntent
                )
            }
            
            Log.d(TAG, "Repeating alarm set successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error setting repeating alarm: ${e.message}")
        }
    }
}
