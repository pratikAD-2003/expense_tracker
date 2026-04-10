/*
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

            val sender = sms.displayOriginatingAddress
            val body = sms.displayMessageBody
            val time = sms.timestampMillis

            val amount = SmsParser.parseAmount(body)

            val type = SmsParser.detectType(body)

            if (amount != null && type != null) {

                Log.d("SMS", "Transaction detected $amount $type")

                db.insertTransaction(
                    sender,
                    amount,
                    type,
                    body,
                    time
                )

                val title =
                    if (type == "debit")
                        "💸 Money Spent"
                    else
                        "💰 Money Received"

                val message = "₹$amount from $sender"

                NotificationHelper.showTransaction(
                    context,
                    title,
                    message
                )
            }
        }
    }
}*/
package com.pratik.pocketca

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import java.security.MessageDigest

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action != "android.provider.Telephony.SMS_RECEIVED") return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)

        val db = SmsDatabase(context)

        for (sms in messages) {

            val sender = sms.displayOriginatingAddress ?: continue
            val body = sms.displayMessageBody ?: continue
            val time = sms.timestampMillis

            // 🔎 Parse SMS
            val result = SmsParser.parse(body)

            if (result == null) {
                Log.d("SMS", "Not a transaction SMS")
                continue
            }

            val amount = result.amount
            val type = result.type
            val merchant = result.merchant
            val category = result.category
            val account = result.account
            val balance = result.balance

            // 🔑 Generate duplicate hash
            val hash = generateHash(
                sender + amount + type + time
            )

            Log.d(
                "SMS",
                "Txn: ₹$amount $type merchant=$merchant"
            )

            // 💾 Save to DB
            db.insertTransaction(
                sender = sender,
                amount = amount,
                type = type,
                merchant = merchant,
                category = category,
                account = account,
                balance = balance,
                message = body,
                time = time,
                hash = hash
            )

            // 🔔 Build notification
            val title =
                if (type == "debit")
                    "💸 Money Spent"
                else
                    "💰 Money Received"

            val message =
                if (merchant != null)
                    "₹$amount at $merchant"
                else
                    "₹$amount transaction"

            NotificationHelper.showTransaction(
                context,
                title,
                message
            )
        }
    }

    // 🔑 SHA-256 hash generator
    private fun generateHash(input: String): String {

        val bytes = MessageDigest
            .getInstance("SHA-256")
            .digest(input.toByteArray())

        return bytes.joinToString("") {
            "%02x".format(it)
        }
    }
}