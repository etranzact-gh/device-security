package com.etranzact.gh.device_security_plus

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DeviceSecurityPlugin */
class DeviceSecurityPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var deviceIdHandler: DeviceIdHandler
    private lateinit var debugModeHandler: DebugModeHandler
    private lateinit var usbConnectionHandler: UsbConnectionHandler
    private lateinit var vpnConnectionHandler: VpnConnectionHandler

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        deviceIdHandler = DeviceIdHandler(flutterPluginBinding.applicationContext)
        debugModeHandler = DebugModeHandler(flutterPluginBinding.applicationContext)
        usbConnectionHandler = UsbConnectionHandler(flutterPluginBinding.applicationContext)
        vpnConnectionHandler = VpnConnectionHandler(flutterPluginBinding.applicationContext)

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_security")
        channel.setMethodCallHandler(this)

        deviceIdHandler.setupChannel(flutterPluginBinding.flutterEngine!!)
        debugModeHandler.setupChannel(flutterPluginBinding.flutterEngine!!)
        usbConnectionHandler.setupChannel(flutterPluginBinding.flutterEngine!!)
        vpnConnectionHandler.setupChannel(flutterPluginBinding.flutterEngine!!)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
