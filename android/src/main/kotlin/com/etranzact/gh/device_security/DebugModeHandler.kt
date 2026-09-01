package com.etranzact.gh.device_security

import android.content.Context
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class DebugModeHandler(private val context: Context) {
    private val channel = "debug_status_channel"

    fun setupChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var contentObserver: ContentObserver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    // Emit initial state immediately
                    val initialAdbEnabled = Settings.Global.getInt(
                        context.contentResolver,
                        Settings.Global.ADB_ENABLED, 0
                    ) == 1
                    events?.success(initialAdbEnabled)

                    contentObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
                        override fun onChange(selfChange: Boolean) {
                            super.onChange(selfChange)
                            val isAdbEnabled = Settings.Global.getInt(
                                context.contentResolver,
                                Settings.Global.ADB_ENABLED, 0
                            ) == 1
                            events?.success(isAdbEnabled)
                        }
                    }
                    
                    val uri = Settings.Global.getUriFor(Settings.Global.ADB_ENABLED)
                    context.contentResolver.registerContentObserver(uri, false, contentObserver!!)
                }

                override fun onCancel(arguments: Any?) {
                    contentObserver?.let {
                        context.contentResolver.unregisterContentObserver(it)
                    }
                    contentObserver = null
                }
            }
        )
    }
}
