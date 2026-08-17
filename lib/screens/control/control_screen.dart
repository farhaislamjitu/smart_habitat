import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return StreamBuilder<DatabaseEvent>(
      stream: databaseService.configStream,
      builder: (context, configSnapshot) {
        bool autoMode = false;
        double interval = 10;

        if (configSnapshot.hasData &&
            configSnapshot.data!.snapshot.value != null) {
          final config = Map<String, dynamic>.from(
              configSnapshot.data!.snapshot.value as Map);
          autoMode = config['autoMode'] as bool? ?? false;
          interval = ((config['interval'] as num?) ?? 10).toDouble();
        }

        return StreamBuilder<DatabaseEvent>(
          stream: databaseService.currentDataStream,
          builder: (context, dataSnapshot) {
            bool ledState = false;
            if (dataSnapshot.hasData &&
                dataSnapshot.data!.snapshot.value != null) {
              final data = Map<String, dynamic>.from(
                  dataSnapshot.data!.snapshot.value as Map);
              ledState = data['ledState'] as bool? ?? false;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Auto/Manual Mode Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          autoMode
                              ? Icons.auto_mode
                              : Icons.pan_tool_alt_outlined,
                          color: autoMode ? Colors.teal : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Auto Mode',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: 1.15,
                          child: Switch(
                            value: autoMode,
                            onChanged: (value) {
                              databaseService.setAutoMode(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. LED Manual Control Card
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
                              color: ledState ? Colors.amber : Colors.grey,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'LED',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1.15,
                          child: Switch(
                            value: ledState,
                            onChanged: autoMode
                                ? null
                                : (value) {
                                    databaseService.setLedState(value);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Interval Slider Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, color: Colors.blueGrey, size: 32),
                                const SizedBox(width: 14),
                                const Text(
                                  'Data Update Interval',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                ),
                              ],
                            ),
                            // Clean numerical overlay display instead of full sentence structure strings
                            Text(
                              '${interval.toInt()}s',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: interval.clamp(2, 60),
                          min: 2,
                          max: 60,
                          divisions: 58,
                          label: '${interval.toInt()}s',
                          onChanged: (value) {
                            databaseService.setInterval(value.toInt());
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('2s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('60s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
