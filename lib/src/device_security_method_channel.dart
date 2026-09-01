import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'device_security_platform_interface.dart';

/// An implementation of [DeviceSecurityPlatform] that uses method channels.
class MethodChannelDeviceSecurity implements DeviceSecurityPlatform {
  /// The method channel used to interact with the native platform.
  final  _deviceIdChannle = const MethodChannel('custom_device_id');
  final  _usbChannel = const EventChannel('usb_status_channel');
  final  _debugChannel = const EventChannel('debug_status_channel');
  final  _vpnChannel = const EventChannel('vpn_status_channel');

  final String _deviceIdKey = 'deviceIdKey';

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  @override
  Stream<bool?> getDebugModeStatus() {
    return _debugChannel.receiveBroadcastStream().map((event) {
      debugPrint('Debug Mode: $event');
      return event as bool?;
    });
  }

  @override
  Future<String?> getDeviceId() async {
    if (Platform.isAndroid) {
      String? nativeId = await _deviceIdChannle.invokeMethod("getDeviceId");
      if (nativeId != null && nativeId.isNotEmpty && nativeId != "unknown") {
        return "android_$nativeId";
      } else {
        AndroidDeviceInfo idInfo = await _deviceInfo.androidInfo;
        return "android_${idInfo.id}";
      }
    } else {
      String? deviceId = await _secureStorage.read(key: _deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
        await _secureStorage.write(key: _deviceIdKey, value: deviceId);
      }
      return "ios_$deviceId";
    }
  }

  @override
  Stream<bool?> getUsbConnectedStatus() {
    return _usbChannel.receiveBroadcastStream().map((event) => event as bool?);
  }

  @override
  Stream<bool?> getVpnConnectionStatus() {
    return _vpnChannel.receiveBroadcastStream().map((event) => event as bool?);
  }
}
