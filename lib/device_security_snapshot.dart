class DeviceSecuritySnapshot {
  final String? deviceId;
  final bool isDebugMode;
  final bool isUsbConnected;
  final bool isVpnConnected;

  DeviceSecuritySnapshot({
    required this.deviceId,
    required this.isDebugMode,
    required this.isUsbConnected,
    required this.isVpnConnected,
  });
}