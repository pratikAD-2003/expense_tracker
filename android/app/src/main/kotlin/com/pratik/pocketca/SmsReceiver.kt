package com.pratik.pocketca

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "android.provider.Telephony.SMS_RECEIVED") return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        val db = SmsDatabase(context)

        for (sms in messages) {
            val body = sms.displayMessageBody ?: continue
            val time = sms.timestampMillis

            val result = SmsParser.parse(body)
            if (result == null) {
                Log.d("SMS", "Not a transaction SMS")
                continue
            }

            val amount = result.amount
            val type = result.type
            val category = result.category
            val title = result.title

            Log.d("SMS", "Txn: ₹$amount $type title=$title category=$category")

            db.insertTransaction(
                type = type,
                category = category,
                amount = amount,
                title = title,
                dateTime = time.toString(),
                source = "SMS",
                rawSms = result.rawSms
            )

            val notificationTitle = if (type == "EXPENSE") "💸 Money Spent" else "💰 Money Received"
            val notificationMessage = "₹$amount at $title"

            NotificationHelper.showTransaction(
                context,
                notificationTitle,
                notificationMessage
            )
        }
    }
}