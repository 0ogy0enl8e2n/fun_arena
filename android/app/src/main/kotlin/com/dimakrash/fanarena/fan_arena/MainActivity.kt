package com.dimakrash.fanarena.fan_arena

import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dimakrash.fanarena/debug_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isUsbDebuggingEnabled" -> {
                        val enabled = Settings.Global.getInt(
                            contentResolver, Settings.Global.ADB_ENABLED, 0
                        ) == 1
                        result.success(enabled)
                    }
                    "getChargingInfo" -> {
                        val batteryIntent = registerReceiver(
                            null,
                            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                        )

                        if (batteryIntent == null) {
                            result.success(
                                mapOf(
                                    "isPlugged" to false,
                                    "batteryLevel" to -1
                                )
                            )
                            return@setMethodCallHandler
                        }

                        val plugged = batteryIntent.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0)
                        val level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                        val scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                        val percentage = if (level >= 0 && scale > 0) {
                            (level * 100) / scale
                        } else {
                            -1
                        }

                        result.success(
                            mapOf(
                                "isPlugged" to (plugged != 0),
                                "batteryLevel" to percentage
                            )
                        )
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
