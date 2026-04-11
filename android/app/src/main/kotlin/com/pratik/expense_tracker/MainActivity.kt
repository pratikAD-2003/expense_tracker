package com.pratik.pocketca

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "native_notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                val db = SmsDatabase(this)

                when (call.method) {

                    "getSms" -> {
                        val data = db.getUnsynced()
                        result.success(data)
                    }

                    "markSmsSynced" -> {
                        val id = call.argument<Int>("id")!!
                        db.markSynced(id)
                        result.success(true)
                    }

                    "addTransaction" -> {
                        val type = call.argument<String>("type") ?: ""
                        val category = call.argument<String>("category") ?: ""
                        val amount = call.argument<Double>("amount") ?: 0.0
                        val title = call.argument<String>("title") ?: ""
                        val dateTime = call.argument<String>("dateTime") ?: ""
                        val source = call.argument<String>("source") ?: "MANUAL"
                        val rawSms = call.argument<String>("rawSms") ?: ""

                        val id = db.insertTransaction(type, category, amount, title, dateTime, source, rawSms)
                        result.success(id.toInt())
                    }

                    "updateTransaction" -> {
                        val id = call.argument<Int>("id")!!
                        val type = call.argument<String>("type") ?: ""
                        val category = call.argument<String>("category") ?: ""
                        val amount = call.argument<Double>("amount") ?: 0.0
                        val title = call.argument<String>("title") ?: ""
                        val dateTime = call.argument<String>("dateTime") ?: ""

                        db.updateTransaction(id, type, category, amount, title, dateTime)
                        result.success(true)
                    }

                    "deleteTransaction" -> {
                        val id = call.argument<Int>("id")!!
                        db.deleteTransaction(id)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
