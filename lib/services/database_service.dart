import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('smart_habitat');

  // Real-time stream of current sensor data
  Stream<DatabaseEvent> get currentDataStream =>
      _dbRef.child('current').onValue;

  // Update LED state manually
  Future<void> setLedState(bool state) async {
    await _dbRef.child('current/ledState').set(state);
  }

  // Real-time stream of config data (autoMode, interval)
  Stream<DatabaseEvent> get configStream => _dbRef.child('config').onValue;

  // Real-time stream of threshold data (temperature/humidity/light limits)
  Stream<DatabaseEvent> get thresholdStream =>
      _dbRef.child('threshold').onValue;

  // Real-time stream of history data (past sensor readings)
  Stream<DatabaseEvent> get historyStream => _dbRef.child('history').onValue;

  // Real-time stream of device connectivity status (single ESP32 for now)
  Stream<DatabaseEvent> get deviceStatusStream =>
      _dbRef.child('devices/esp32_1').onValue;

  // Update a threshold value (metric: temperature/humidity/light,
  // level: warning/critical)
  Future<void> setThreshold(String metric, String level, num value) async {
    await _dbRef.child('threshold/$metric/$level').set(value);
  }

  // Toggle auto/manual mode
  Future<void> setAutoMode(bool state) async {
    await _dbRef.child('config/autoMode').set(state);
  }

  // Update data-fetch interval (seconds)
  Future<void> setInterval(int seconds) async {
    await _dbRef.child('config/interval').set(seconds);
  }
}