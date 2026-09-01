import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:device_security/device_security.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _deviceId = 'Unknown';
  Stream<bool?>? _usbConnected;
  Stream<bool?>? _debugMode;
  Stream<bool?>? _vpnConnected;
  final _deviceSecurityPlugin = DeviceSecurity();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String deviceId;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
   
      deviceId =
          await _deviceSecurityPlugin.getDeviceId() ?? 'Unknown Device ID';
      _usbConnected = _deviceSecurityPlugin.getUsbConnectedStatus();
      _debugMode = _deviceSecurityPlugin.getDebugModeStatus();
      _vpnConnected = _deviceSecurityPlugin.getVpnConnectionStatus();
    } on PlatformException {
      deviceId = 'Failed to get device ID';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            children: [
           
              Text('Device ID: $_deviceId\n'),
              StreamBuilder<bool?>(
                stream: _usbConnected,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('USB Connected: ${snapshot.data}\n');
                  }
                  return const Text('USB Connected: Unknown\n');
                },
              ),
              StreamBuilder<bool?>(
                stream: _debugMode,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('Debug Mode: ${snapshot.data}\n');
                  }
                  return const Text('Debug Mode: Unknown\n');
                },
              ),
              StreamBuilder<bool?>(
                stream: _vpnConnected,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('VPN Connected: ${snapshot.data}\n');
                  }
                  return const Text('VPN Connected: Unknown\n');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
