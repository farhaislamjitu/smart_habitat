import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class MultiDeviceScreen extends StatelessWidget {
  const MultiDeviceScreen({super.key});

  void _showAddDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Device'),
        // FIXED: Completely removed the explanation sentence
        content: const Text('Only one device supported at this time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Devices')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseService.currentDataStream,
        builder: (context, snapshot) {
          bool hasData =
              snapshot.hasData && snapshot.data!.snapshot.value != null;
          String status = 'Offline';
          Color statusColor = Colors.grey;

          if (hasData) {
            final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            status = data['status'] as String? ?? 'Normal';
            statusColor = Colors.green;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.developer_board,
                            color: statusColor, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Smart Habitat ESP32',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: hasData
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasData ? 'Online' : 'Offline',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '• Status: $status',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: Colors.teal, size: 22),
                    ],
                  ),
                ),
              ),
              // FIXED: Completely removed the bottom text padding and string widget as requested
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
