# device_security

A Flutter plugin to retrieve unique device identifiers and monitor real-time security statuses across iOS and Android.

This package provides a unified API to detect if a device is using a VPN, has a debugger attached, is connected via USB, and provides a persistent, hardware-backed unique device identifier. It is designed with performance and ease-of-use in mind, offering both granular real-time streams and one-off consolidated snapshots.

## Features

- **Unique Device ID**: Retrieves a persistent, hardware-backed unique identifier.
  - *Android*: Uses Widevine DRM ID with a fallback to the OS `ANDROID_ID`.
  - *iOS*: Uses the Vendor ID and securely persists it across app reinstalls using the iOS Keychain.
- **VPN Detection**: Detects if network traffic is being routed through a VPN (e.g., tun, tap, ipsec).
- **Debug Mode Detection**: Detects if the app is currently running under a debugger or if developer mode is enabled.
- **USB Connection Status**: Detects if the device is currently plugged in via USB.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  device_security: ^latest_version
```

### iOS Setup Note
If you are testing the **Device ID** generation on an iOS Simulator, you may need to enable the **Keychain Sharing** capability in Xcode for the `flutter_secure_storage` dependency to work properly. This is only necessary for the simulator; real devices do not require any configuration. No user-facing permissions are required.

## Usage

First, instantiate the plugin:
```dart
import 'package:device_security/device_security.dart';

final deviceSecurity = DeviceSecurity();
```

There are two primary ways to use this package depending on your needs:

### 1. One-Time Snapshot (Great for app startup/login)
If you just want to do a quick security check before letting a user log in, use the `getSecuritySnapshot()` method. It queries all statuses concurrently and returns a consolidated `DeviceSecuritySnapshot` object.

```dart
Future<void> checkSecurity() async {
  final snapshot = await deviceSecurity.getSecuritySnapshot();

  print('Device ID: ${snapshot.deviceId}');
  print('Is VPN Active: ${snapshot.isVpnConnected}');
  print('Is Debug Mode On: ${snapshot.isDebugMode}');
  print('Is USB Connected: ${snapshot.isUsbConnected}');
  
  if (snapshot.isVpnConnected) {
    // Block user or show warning
  }
}
```

### 2. Live Monitoring (Great for active security enforcement)
If you want your UI or app state to react instantly if a user plugs in a USB or turns on a VPN mid-session, use the individual `Stream` methods.

```dart
// Monitor VPN Status
StreamBuilder<bool?>(
  stream: deviceSecurity.getVpnConnectionStatus(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data == true) {
      return Text('Warning: VPN is currently active!');
    }
    return Text('Connection is secure.');
  },
);

// Monitor Debug Mode
deviceSecurity.getDebugModeStatus().listen((isDebug) {
  if (isDebug == true) {
    print("Debugger attached!");
  }
});
```

## Platform Specific Limitations

Apple heavily restricts access to hardware states on iOS. As a result, the iOS implementation uses the closest available proxies:
- **USB Connection (iOS)**: Apple provides no public API to distinguish between a wall charger and a USB data connection. On iOS, the `isUsbConnected` boolean will return `true` anytime the device is plugged into power.
- **Debug Mode (iOS)**: Checks the process flags (`P_TRACED`) via `sysctl` to see if a debugger like Xcode is actively attached. It does not read the global "Developer Mode" toggle from iOS Settings.
