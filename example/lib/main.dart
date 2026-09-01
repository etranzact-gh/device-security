import 'package:flutter/material.dart';
import 'package:device_security/device_security.dart';
import 'package:device_security/device_security_snapshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _deviceSecurityPlugin = DeviceSecurity();

  // State for the one-time snapshot
  DeviceSecuritySnapshot? _snapshot;
  bool _isLoadingSnapshot = false;

  // Streams for live monitoring
  late final Stream<bool?> _usbStream;
  late final Stream<bool?> _debugStream;
  late final Stream<bool?> _vpnStream;

  @override
  void initState() {
    super.initState();
    
    // 1. Initialize live streams
    _usbStream = _deviceSecurityPlugin.getUsbConnectedStatus();
    _debugStream = _deviceSecurityPlugin.getDebugModeStatus();
    _vpnStream = _deviceSecurityPlugin.getVpnConnectionStatus();

    // 2. Fetch initial snapshot
    _fetchSnapshot();
  }

  Future<void> _fetchSnapshot() async {
    setState(() => _isLoadingSnapshot = true);
    try {
      final snapshot = await _deviceSecurityPlugin.getSecuritySnapshot();
      if (mounted) {
        setState(() => _snapshot = snapshot);
      }
    } catch (e) {
      debugPrint("Error fetching snapshot: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingSnapshot = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Security Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSnapshotCard(),
              const SizedBox(height: 24),
              _buildLiveMonitoringCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. Startup Snapshot',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoadingSnapshot ? null : _fetchSnapshot,
                  tooltip: 'Refresh Snapshot',
                ),
              ],
            ),
            const Text(
              'A one-time check, perfect for app launch.',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            if (_isLoadingSnapshot)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_snapshot != null) ...[
              _buildStatusRow('Device ID', _snapshot!.deviceId ?? 'Unknown', Icons.perm_device_information),
              _buildStatusRow('USB Connected', _snapshot!.isUsbConnected.toString(), Icons.usb),
              _buildStatusRow('Debug Mode', _snapshot!.isDebugMode.toString(), Icons.bug_report),
              _buildStatusRow('VPN Connected', _snapshot!.isVpnConnected.toString(), Icons.vpn_lock),
            ] else
              const Text('Failed to load snapshot.'),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMonitoringCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Live Monitoring',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'Continuous streams that react instantly to changes.',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            _buildLiveStreamRow('USB Connected', _usbStream, Icons.usb),
            _buildLiveStreamRow('Debug Mode', _debugStream, Icons.bug_report),
            _buildLiveStreamRow('VPN Connected', _vpnStream, Icons.vpn_lock),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStreamRow(String title, Stream<bool?> stream, IconData icon) {
    return StreamBuilder<bool?>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? snapshot.data.toString() : 'Waiting...';
        return _buildStatusRow(title, value, icon, isLive: true);
      },
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, {bool isLive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: isLive ? Colors.blue : Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              // Highlights 'true' (usually bad for security) in red, 'false' in green.
              color: value == 'true' ? Colors.red : (value == 'false' ? Colors.green : Colors.grey),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
