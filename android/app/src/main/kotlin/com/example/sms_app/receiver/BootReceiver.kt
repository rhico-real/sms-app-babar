package com.basroot.sms.app.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.basroot.sms.app.service.SmsListenerService

/**
 * A broadcast receiver that starts the SMS listener service when the device boots up
 */
class BootReceiver : BroadcastReceiver() {
    private val TAG = "BootReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Boot completed received")
        
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            try {
                // Start the SMS listener service when device boots up
                val serviceIntent = Intent(context, SmsListenerService::class.java)
                
                // For Android 8.0+, start the service as a foreground service
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                
                Log.d(TAG, "SMS Listener service started after boot")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting service after boot: ${e.message}")
            }
        }
    }
}