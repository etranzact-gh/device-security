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
  @visibleForTesting
  final methodChannel = const MethodChannel('custom_device_id');
  static const _usbChannel = EventChannel('usb_status_channel');
  static const _debugChannel = EventChannel('debug_status_channel');
  static const _vpnChannel = EventChannel('vpn_status_channel');

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
      // 1. Try your custom native DRM channel first
      String? nativeId = await methodChannel.invokeMethod("getDeviceId");
      if (nativeId != null && nativeId.isNotEmpty && nativeId != "unknown") {
        return "android_$nativeId";
      } else {
        // 2. Fallback to device_info_plus (ANDROID_ID)
        AndroidDeviceInfo idInfo = await _deviceInfo.androidInfo;
        return "android_${idInfo.id}";
      }
    } else {
      // 1. Check Keychain for an existing ID
      String? deviceId = await _secureStorage.read(key: _deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        // 2. First run or keychain was cleared: grab vendor ID or generate a new UUID
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
        // 3. Save it permanently to the Keychain
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
