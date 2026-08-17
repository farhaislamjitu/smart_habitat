import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Warning':
        return AppTheme.statusWarning;
      case 'Critical':
        return AppTheme.statusCritical;
      default:
        return AppTheme.statusNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return StreamBuilder<DatabaseEvent>(
      stream: databaseService.currentDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('কোনো data পাওয়া যায়নি'));
        }

        final data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        final double temperature =
            (data['temperature'] as num?)?.toDouble() ?? 0;
        final double humidity = (data['humidity'] as num?)?.toDouble() ?? 0;
        final double light = (data['light'] as num?)?.toDouble() ?? 0;
        final String status = data['status'] as String? ?? 'Normal';
        final bool ledState = data['ledState'] as bool? ?? false;

        // FIXED: Stripped away Scaffold and AppBar completely. 
        // This widget now drops perfectly into MainNavigation's frame.
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Card
              Card(
                color: _statusColor(status).withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: _statusColor(status), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'Environment Status: $status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sensor cards row
              Row(
                children: [
                  Expanded(
                    child: _SensorCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '${temperature.toStringAsFixed(1)}°C',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SensorCard(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${humidity.toStringAsFixed(0)}%',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SensorCard(
                icon: Icons.wb_sunny,
                label: 'Light Intensity',
                value: '${light.toStringAsFixed(0)} lx',
                color: Colors.amber,
                fullWidth: true,
              ),
              const SizedBox(height: 18),

              // LED Control Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 32,
                            color: ledState ? Colors.amber : Colors.grey,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'LED Control',
                            style: TextStyle(
                              fontWeight: FontWeight.w700, 
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 1.15,
                        child: Switch(
                          value: ledState,
                          onChanged: (value) {
                            databaseService.setLedState(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _SensorCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
