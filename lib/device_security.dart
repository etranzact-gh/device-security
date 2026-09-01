import 'package:device_security_plus/device_security_snapshot.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'device_security_platform_interface.dart';

/// A plugin for accessing device security information and status.
///
/// This class provides methods to retrieve unique device identifiers and
/// streams to monitor the real-time status of various security-related
/// device features, such as USB connections, debug mode, and VPN usage.
class DeviceSecurity {
  /// Retrieves a unique identifier for the device.
  ///
  /// On Android, this attempts to use a hardware-backed Widevine DRM ID,
  /// falling back to the Android ID (`device_info_plus`) if unavailable.
  /// On iOS, this generates a unique UUID or uses the vendor ID, and securely
  /// persists it in the iOS Keychain across app reinstalls.
  ///
  /// Returns a `Future<String?>` containing the device ID, prefixed with
  /// either `android_` or `ios_`.
  Future<String?> getDeviceId() {
    return DeviceSecurityPlatform.instance.getDeviceId();
  }

  /// A stream that emits the current USB connection status.
  ///
  /// Emits `true` if the device is currently connected via USB (or plugged into
  /// power on iOS), and `false` otherwise. The stream emits the initial state
  /// immediately upon subscription and updates continuously.
  Stream<bool?> getUsbConnectedStatus() {
    return DeviceSecurityPlatform.instance.getUsbConnectedStatus();
  }

  /// A stream that emits the current debug mode status.
  ///
  /// On Android, this checks if ADB/USB Debugging is enabled in Developer Options.
  /// On iOS, this checks if the app is currently running under a debugger (e.g., Xcode).
  /// Emits `true` if debug mode is active, and `false` otherwise.
  Stream<bool?> getDebugModeStatus() {
    return DeviceSecurityPlatform.instance.getDebugModeStatus();
  }

  /// A stream that emits the current VPN connection status.
  ///
  /// Emits `true` if the device's network traffic is currently being routed
  /// through a VPN interface (e.g., tun, tap, ipsec), and `false` otherwise.
  Stream<bool?> getVpnConnectionStatus() {
    return DeviceSecurityPlatform.instance.getVpnConnectionStatus();
  }

  /// Retrieves a consolidated snapshot of all security statuses at once.
  ///
  /// This is useful for performing a single, comprehensive security check
  /// (e.g., during app startup or login) without having to manage multiple
  /// subscriptions.
  ///
  /// Note: The status checks time out after 2 seconds and default to `false`
  /// to prevent the app from hanging if the native platform fails to respond.
  Future<DeviceSecuritySnapshot> getSecuritySnapshot() async {
    // Fire them all off concurrently for speed
    final results = await Future.wait([
      getDeviceId(),
      getUsbConnectedStatus().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Usb connected status timed out');
          return false;
        },
      ),
      getDebugModeStatus().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Debug mode status timed out');
          return false;
        },
      ),
      getVpnConnectionStatus().first.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Vpn connection status timed out');
          return false;
        },
      ),
    ]);
    return DeviceSecuritySnapshot(
      deviceId: results[0] as String?,
      isUsbConnected: (results[1] as bool?) ?? false,
      isDebugMode: (results[2] as bool?) ?? false,
      isVpnConnected: (results[3] as bool?) ?? false,
    );
  }
}
