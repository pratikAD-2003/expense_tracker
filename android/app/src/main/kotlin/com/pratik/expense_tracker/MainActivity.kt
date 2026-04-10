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

                    else -> result.notImplemented()
                }
            }
    }
}