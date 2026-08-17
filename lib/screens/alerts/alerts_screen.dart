import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Critical':
        return AppTheme.statusCritical;
      case 'Warning':
        return AppTheme.statusWarning;
      default:
        return AppTheme.statusNormal;
    }
  }

  IconData _statusIcon(String status) {
    if (status == 'Critical') return Icons.error;
    if (status == 'Warning') return Icons.warning_amber_rounded;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: Column(
        children: [
          // Live current status banner (real-time)
          StreamBuilder<DatabaseEvent>(
            stream: databaseService.currentDataStream,
            builder: (context, snapshot) {
              String status = 'Normal';
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);
                status = data['status'] as String? ?? 'Normal';
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(status), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(status), color: _statusColor(status)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'Normal'
                                ? 'Normal'
                                : 'Live: $status Alert!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _statusColor(status),
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            'Real-time current status',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alert History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),

          // Alert history list
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: databaseService.historyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No data found!'));
                }

                final raw = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                final alerts = raw.entries
                    .map((e) => {
                          'time': e.key,
                          'data': Map<String, dynamic>.from(e.value as Map),
                        })
                    .where((e) {
                  final status = (e['data']
                          as Map<String, dynamic>)['status'] as String? ??
                      'Normal';
                  return status != 'Normal';
                }).toList()
                  ..sort((a, b) =>
                      (b['time'] as String).compareTo(a['time'] as String));

                if (alerts.isEmpty) {
                  return const Center(
                    child: Text('No Warning/Critical alert history!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final entry = alerts[index];
                    final data = entry['data'] as Map<String, dynamic>;
                    final status = data['status'] as String? ?? 'Warning';
                    final temperature =
                        (data['temperature'] as num?)?.toDouble() ?? 0;
                    final humidity =
                        (data['humidity'] as num?)?.toDouble() ?? 0;
                    final light = (data['light'] as num?)?.toDouble() ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: _statusColor(status).withValues(alpha: 0.08),
                      child: ListTile(
                        leading: Icon(_statusIcon(status),
                            color: _statusColor(status)),
                        title: Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _statusColor(status),
                          ),
                        ),
                        subtitle: Text(
                          '${entry['time']}\n'
                          'Temp: ${temperature.toStringAsFixed(1)}°C  •  '
                          'Humidity: ${humidity.toStringAsFixed(0)}%  •  '
                          'Light: ${light.toStringAsFixed(0)} lx',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}