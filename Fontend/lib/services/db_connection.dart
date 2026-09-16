import 'package:mysql1/mysql1.dart';
import 'db_config.dart';

/// DbConnection: the ONLY class that opens a socket to MySQL.
/// CategoryService / TransactionService / BudgetService all get their
/// connection from here and write plain SQL - no API server involved.
class DbConnection {
  DbConnection._internal();
  static MySqlConnection? _conn;

  static Future<MySqlConnection> get connection async {
    final existing = _conn;
    if (existing != null) return existing;

    final settings = ConnectionSettings(
      host: DbConfig.host,
      port: DbConfig.port,
      user: DbConfig.user,
      password: DbConfig.password,
      db: DbConfig.dbName,
    );
    final conn = await MySqlConnection.connect(settings).timeout(
      const Duration(seconds: 8),
      onTimeout: () => throw Exception(
        'Could not reach MySQL at ${DbConfig.host}:${DbConfig.port} within 8s. '
        'Check: is MySQL running? is the host/IP correct for your device? '
        'is port 3306 open in your firewall?',
      ),
    );
    _conn = conn;
    return conn;
  }

  static Future<void> close() async {
    await _conn?.close();
    _conn = null;
  }
}

// Small helpers because mysql1 sometimes returns num/BigInt depending on
// the exact column type - these keep the service files simple.
int dbToInt(dynamic value) => value is int ? value : (value as num).toInt();

double dbToDouble(dynamic value) => value is double ? value : (value as num).toDouble();

DateTime dbToDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.parse(value.toString());
}
