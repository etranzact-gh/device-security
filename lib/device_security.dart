import 'device_security_platform_interface.dart';

class DeviceSecurity {
  Future<String?> getDeviceId() {
    return DeviceSecurityPlatform.instance.getDeviceId();
  }

  Stream<bool?> getUsbConnectedStatus() {
    return DeviceSecurityPlatform.instance.getUsbConnectedStatus();
  }

  Stream<bool?> getDebugModeStatus() {
    return DeviceSecurityPlatform.instance.getDebugModeStatus();
  }

  Stream<bool?> getVpnConnectionStatus() {
    return DeviceSecurityPlatform.instance.getVpnConnectionStatus();
  }
}
