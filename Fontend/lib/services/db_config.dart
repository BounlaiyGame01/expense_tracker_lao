/// MySQL connection settings for connecting the Flutter app DIRECTLY to the
/// database (no API layer in between). This is fine for a local demo /
/// school project, but keep in mind: this means the phone/emulator running
/// the app must be able to reach the MySQL server over the network, and the
/// database credentials are bundled inside the app.
class DbConfig {
  /// Android emulator -> '10.0.2.2' reaches your PC's 'localhost'.
  /// iOS simulator     -> '127.0.0.1'
  /// Real phone (same Wi-Fi as your PC) -> your PC's LAN IP, e.g. '192.168.1.23'
  static const String host = 'localhost';
  static const int port = 3306;
  static const String user = 'root';
  static const String password = '12345678';
  static const String dbName = 'expense_tracker_lao';
}
