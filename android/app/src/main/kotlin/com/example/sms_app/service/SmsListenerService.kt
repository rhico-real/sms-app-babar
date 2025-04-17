package com.example.sms_app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.sms_app.MainActivity

/**
 * A foreground service to keep the SMS listener running even when the app is in background
 */
class SmsListenerService : Service() {
    private val TAG = "SmsListenerService"
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "sms_listener_foreground"

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "SMS Listener Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "SMS Listener Service started")
        
        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SMS Listener Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps the SMS listener running in background"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
        
        // Intent to launch the app when notification is tapped
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
        
        // Build the notification - ensuring it matches the Flutter-created one
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BABAR SMS Listener")
            .setContentText("Listening for appointment SMS messages")
            .setSmallIcon(resources.getIdentifier("ic_launcher", "mipmap", packageName))
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .build()
        
        // Start as a foreground service with the notification
        startForeground(NOTIFICATION_ID, notification)
        
        // Return START_STICKY to ensure the service is restarted if killed by the system
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        Log.d(TAG, "SMS Listener Service destroyed")
        
        try {
            // Remove the notification when service is destroyed
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(NOTIFICATION_ID)
        } catch (e: Exception) {
            Log.e(TAG, "Error removing notification: ${e.message}")
        }
        
        super.onDestroy()
    }
}
