package package com.etranzact.gh.device_security

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class UsbConnectionHandler(private val context: Context) {
    private val channel = "usb_status_channel"

    fun setupChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var receiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    receiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            val connected = intent.extras?.getBoolean("connected") ?: false
                            events?.success(connected)
                        }
                    }
                    val filter = IntentFilter("android.hardware.usb.action.USB_STATE")
                    context.registerReceiver(receiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    receiver?.let { context.unregisterReceiver(it) }
                    receiver = null
                }
            }
        )
    }
}