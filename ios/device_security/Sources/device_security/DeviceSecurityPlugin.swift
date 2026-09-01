import Flutter
import UIKit

public class DeviceSecurityPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_security", binaryMessenger: registrar.messenger())
    let instance = DeviceSecurityPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // Register VPN Status Channel
    let vpnChannel = FlutterEventChannel(name: "vpn_status_channel", binaryMessenger: registrar.messenger())
    vpnChannel.setStreamHandler(VpnConnectionHandler())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
