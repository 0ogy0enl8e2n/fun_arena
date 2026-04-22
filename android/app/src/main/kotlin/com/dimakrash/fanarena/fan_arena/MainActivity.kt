package com.dimakrash.fanarena.fan_arena

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
                if (call.method == "isUsbDebuggingEnabled") {
                    val enabled = Settings.Global.getInt(
                        contentResolver, Settings.Global.ADB_ENABLED, 0
                    ) == 1
                    result.success(enabled)
                } else {
                    result.notImplemented()
                }
            }
    }
}
