package com.resqnet.resqnet

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Set up Android notification channels for emergency alerts
        NotificationHelper.createNotificationChannels(this)
        // Register Native Bridge MethodChannel
        ResQnetNativeBridge.registerWith(flutterEngine, this)
    }
}
