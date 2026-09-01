package com.etranzact.gh.device_security_plus

import android.content.Context
import android.media.MediaDrm
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class DeviceIdHandler(private val context: Context) {
    private val channel = "custom_device_id"

    fun setupChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceId") {
                // Try getting the Hardware DRM ID first, fallback to Android ID
                val deviceId = getWidevineId() ?: getAndroidId()
                result.success(deviceId)
            } else {
                result.notImplemented()
            }
        }
    }

    // 1. Hardware-backed ID via Widevine DRM (Persists across reinstalls)
    private fun getWidevineId(): String? {
        return try {
            val widevineUuid = UUID.fromString("edef8ba9-79d6-4ace-a3c8-27dcd51d21ed")
            val mediaDrm = MediaDrm(widevineUuid)
            val widevineIdBytes = mediaDrm.getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                mediaDrm.close()
            } else {
                mediaDrm.release()
            }

            // Convert raw bytes to a readable Hex String
            widevineIdBytes.joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            e.printStackTrace()
            null // Fallback if hardware DRM fails
        }
    }

    // 2. OS-assigned Android ID (Persists across reinstallations per developer key)
    private fun getAndroidId(): String {
        return Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown"
    }
}
