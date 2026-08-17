import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _metrics = ['Temperature', 'Humidity', 'Light'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _metrics.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  double _valueFor(String metric, Map<String, dynamic> entry) {
    switch (metric) {
      case 'Temperature':
        return (entry['temperature'] as num?)?.toDouble() ?? 0;
      case 'Humidity':
        return (entry['humidity'] as num?)?.toDouble() ?? 0;
      case 'Light':
        return (entry['light'] as num?)?.toDouble() ?? 0;
      default:
        return 0;
    }
  }

  String _unitFor(String metric) {
    switch (metric) {
      case 'Temperature':
        return '°C';
      case 'Humidity':
        return '%';
      case 'Light':
        return 'lx';
      default:
        return '';
    }
  }

  Color _colorFor(String metric) {
    switch (metric) {
      case 'Temperature':
        return Colors.orange;
      case 'Humidity':
        return Colors.blue;
      case 'Light':
        return Colors.amber;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return StreamBuilder<DatabaseEvent>(
      stream: databaseService.historyStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text(
              'No historical logs available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final raw =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        final sortedKeys = raw.keys.toList()..sort();

        final entries = sortedKeys.map((key) {
          return {
            'time': key,
            'data': Map<String, dynamic>.from(raw[key] as Map),
          };
        }).toList();

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: _metrics.map((m) => Tab(text: m)).toList(),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _metrics.map((metric) {
                  return _MetricView(
                    metric: metric,
                    entries: entries,
                    unit: _unitFor(metric),
                    color: _colorFor(metric),
                    valueFor: _valueFor,
                    statusColor: _statusColor,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
class _MetricView extends StatefulWidget {
  final String metric;
  final List<Map<String, dynamic>> entries;
  final String unit;
  final Color color;
  final double Function(String, Map<String, dynamic>) valueFor;
  final Color Function(String) statusColor;

  const _MetricView({
    required this.metric,
    required this.entries,
    required this.unit,
    required this.color,
    required this.valueFor,
    required this.statusColor,
  });

  @override
  State<_MetricView> createState() => _MetricViewState();
}

class _MetricViewState extends State<_MetricView> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final spots = <FlSpot>[];
    for (int i = 0; i < widget.entries.length; i++) {
      final data = widget.entries[i]['data'] as Map<String, dynamic>;
      spots.add(FlSpot(i.toDouble(), widget.valueFor(widget.metric, data)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 22, 14),
            child: SizedBox(
              height: 230,
              child: spots.isEmpty
                  ? const Center(child: Text('No data plotted', style: TextStyle(color: Colors.grey)))
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => widget.color.withValues(alpha: 0.9),
                            tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
                            getTooltipItems: (List<LineBarSpot> touchedSpots) { // FIXED: Changed type to LineBarSpot
                              return touchedSpots.map((barSpot) {
                                return LineTooltipItem(
                                  '${barSpot.y.toStringAsFixed(1)} ${widget.unit}', // FIXED: Reverted to direct .y accessor
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 6,
                                  child: Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: widget.color,
                            barWidth: 3.5,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: widget.color.withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.entries.reversed.map((entry) {
          final data = entry['data'] as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'Normal';
          final value = widget.valueFor(widget.metric, data);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.circle, color: widget.statusColor(status), size: 16),
                title: Text(
                  '${value.toStringAsFixed(1)} ${widget.unit}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    entry['time'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
                trailing: Text(
                  status,
                  style: TextStyle(
                    color: widget.statusColor(status),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
