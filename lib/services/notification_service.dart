import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  String? _lastStatus;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);

    // Android 13+ runtime notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Call this whenever new sensor status arrives. Only notifies on
  // Normal -> Warning/Critical transitions (not on every stream tick).
  Future<void> notifyIfStatusChanged(String status) async {
    if (status != 'Normal' && status != _lastStatus) {
      await _show(status);
    }
    _lastStatus = status;
  }

  Future<void> _show(String status) async {
    final isCritical = status == 'Critical';

    final androidDetails = AndroidNotificationDetails(
      'smart_habitat_alerts',
      'Environment Alerts',
      channelDescription: 'Notifies when sensor readings become abnormal',
      importance: isCritical ? Importance.max : Importance.high,
      priority: isCritical ? Priority.max : Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 0,
      title: isCritical ? '⚠️ Critical Alert' : '⚠️ Warning',
      body: isCritical
          ? 'Environment critical range-e pouche geche, ekhoni check korun'
          : 'Environment warning range-e ache, khoyal rakhun',
      notificationDetails: details,
    );
  }
}