package com.resqnet.resqnet

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ResQnetNativeBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.resqnet/native_bridge"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            val bridge = ResQnetNativeBridge(context)
            channel.setMethodCallHandler(bridge)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setupNotificationChannels" -> {
                NotificationHelper.createNotificationChannels(context)
                result.success(true)
            }
            "triggerNativeEmergencyFeedback" -> {
                triggerHapticFeedback()
                result.success(true)
            }
            "checkNotificationChannelStatus" -> {
                result.success(checkChannelStatus())
            }
            "showEmergencyNotification" -> {
                val title = call.argument<String>("title") ?: "ResQnet Emergency Alert"
                val body = call.argument<String>("body") ?: "A community member needs urgent assistance."
                NotificationHelper.showNotification(context, title, body)
                result.success(true)
            }
            "getDevicePlatformInfo" -> {
                val info = mapOf(
                    "platform" to "Android",
                    "sdkVersion" to Build.VERSION.SDK_INT,
                    "model" to Build.MODEL,
                    "manufacturer" to Build.MANUFACTURER
                )
                result.success(info)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun triggerHapticFeedback() {
        val pattern = longArrayOf(0, 400, 150, 400, 150, 600)
        val amplitudes = intArrayOf(0, 255, 0, 255, 0, 255)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            val vibrator = vibratorManager?.defaultVibrator
            if (vibrator != null && vibrator.hasVibrator()) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, amplitudes, -1))
            }
        } else {
            @Suppress("DEPRECATION")
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            if (vibrator != null && vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(pattern, -1)
                }
            }
        }
    }

    private fun checkChannelStatus(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            val channel = notificationManager.getNotificationChannel(NotificationHelper.EMERGENCY_CHANNEL_ID)
            return channel != null && channel.importance != android.app.NotificationManager.IMPORTANCE_NONE
        }
        return true
    }
}
