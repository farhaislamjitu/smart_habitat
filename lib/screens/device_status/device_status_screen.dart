import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class DeviceStatusScreen extends StatelessWidget {
  const DeviceStatusScreen({super.key});

  String _signalLabel(int rssi) {
    if (rssi >= -55) return 'Excellent';
    if (rssi >= -67) return 'Good';
    if (rssi >= -75) return 'Fair';
    return 'Weak';
  }

  IconData _signalIcon(int rssi) {
    if (rssi >= -55) return Icons.wifi;
    if (rssi >= -67) return Icons.wifi_2_bar;
    if (rssi >= -75) return Icons.wifi_1_bar;
    return Icons.wifi_off;
  }

  Color _signalColor(int rssi) {
    if (rssi >= -55) return Colors.green;
    if (rssi >= -67) return Colors.lightGreen;
    if (rssi >= -75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Device Status')),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseService.deviceStatusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('কোনো device data পাওয়া যায়নি'));
          }

          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final bool online = data['online'] as bool? ?? false;
          final String lastSeen = data['lastSeen'] as String? ?? '-';
          final int wifiSignal = (data['wifiSignal'] as num?)?.toInt() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Online/Offline status card
              Card(
                color: (online ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        online ? Icons.check_circle : Icons.cancel,
                        color: online ? Colors.green : Colors.red,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            online ? 'ESP32 Online' : 'ESP32 Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: online ? Colors.green : Colors.red,
                            ),
                          ),
                          const Text(
                            'esp32_1',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Last synced card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sync, color: Colors.blueGrey),
                  title: const Text('Last Synced'),
                  subtitle: Text(lastSeen),
                ),
              ),
              const SizedBox(height: 8),

              // WiFi signal card
              Card(
                child: ListTile(
                  leading: Icon(_signalIcon(wifiSignal),
                      color: _signalColor(wifiSignal)),
                  title: const Text('WiFi Signal'),
                  subtitle: Text(
                    '$wifiSignal dBm  •  ${_signalLabel(wifiSignal)}',
                    style: TextStyle(color: _signalColor(wifiSignal)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}