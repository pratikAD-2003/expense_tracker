package com.pratik.pocketca

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {

    private const val PREFS_NAME = "app_settings"
    private const val KEY_NOTIFICATIONS = "isNotificationsEnabled"
    private const val KEY_SOUND = "isSoundEnabled"

    fun showTransaction(
        context: Context,
        title: String,
        body: String
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val isNotificationsEnabled = prefs.getBoolean(KEY_NOTIFICATIONS, true)
        val isSoundEnabled = prefs.getBoolean(KEY_SOUND, true)

        if (!isNotificationsEnabled) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Dynamic Channel ID based on sound setting to handle Android's channel behavior
        val channelId = if (isSoundEnabled) "transactions_with_sound_v1" else "transactions_silent_v1"
        val channelName = if (isSoundEnabled) "Transactions (Sound)" else "Transactions (Silent)"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance)
            
            if (isSoundEnabled) {
                val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + context.packageName + "/raw/transaction_sound")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                channel.setSound(soundUri, audioAttributes)
            } else {
                channel.setSound(null, null)
            }

            manager.createNotificationChannel(channel)
        }

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        if (isSoundEnabled) {
            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + context.packageName + "/raw/transaction_sound")
            builder.setSound(soundUri)
        }

        manager.notify(System.currentTimeMillis().toInt(), builder.build())
    }
}