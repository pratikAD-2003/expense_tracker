package com.pratik.pocketca

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "native_notification"
    private val PREFS_NAME = "app_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                val db = SmsDatabase(this)
                val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

                when (call.method) {
                    "getSettings" -> {
                        val settings = mapOf(
                            "isNotificationsEnabled" to prefs.getBoolean("isNotificationsEnabled", true),
                            "isSoundEnabled" to prefs.getBoolean("isSoundEnabled", true)
                        )
                        result.success(settings)
                    }

                    "updateSetting" -> {
                        val key = call.argument<String>("key")!!
                        val value = call.argument<Boolean>("value")!!
                        prefs.edit().putBoolean(key, value).apply()
                        result.success(true)
                    }

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

                    "openAutoStartSettings" -> {
                        openAutoStartSettings()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun openAutoStartSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.ROOT)
        val intent = Intent()

        try {
            when {
                manufacturer.contains("xiaomi") -> {
                    intent.component = ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                }
                manufacturer.contains("oppo") -> {
                    intent.component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                }
                manufacturer.contains("vivo") -> {
                    intent.component = ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                }
                manufacturer.contains("letv") -> {
                    intent.component = ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity")
                }
                manufacturer.contains("honor") || manufacturer.contains("huawei") -> {
                    intent.component = ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")
                }
                else -> {
                    // For other devices, open app settings or power management
                    intent.action = android.provider.Settings.ACTION_SETTINGS
                }
            }

            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback to general settings
            try {
                val fallbackIntent = Intent(android.provider.Settings.ACTION_SETTINGS)
                fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(fallbackIntent)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }
}
