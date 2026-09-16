import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

/// ApiClient: the only class that knows how to talk HTTP to the Python
/// (FastAPI) backend. CategoryService / TransactionService / BudgetService
/// all sit on top of this.
class ApiClient {
  static const _timeout = Duration(seconds: 8);

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  static Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query)).timeout(_timeout, onTimeout: _onTimeout);
    _checkStatus(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http
        .post(_uri(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(_timeout, onTimeout: _onTimeout);
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http
        .put(_uri(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(_timeout, onTimeout: _onTimeout);
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(_uri(path)).timeout(_timeout, onTimeout: _onTimeout);
    _checkStatus(res);
  }

  static http.Response _onTimeout() {
    throw ApiException(
      'Could not reach the backend at ${ApiConfig.baseUrl} within 8s. '
      'Check: is "uvicorn app.main:app" running? is the IP in api_config.dart '
      'correct? are your phone and PC on the same Wi-Fi? is port 8000 open '
      'in your firewall?',
    );
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('${res.statusCode}: ${res.body}');
    }
  }
}
