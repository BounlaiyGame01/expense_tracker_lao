/// Points the Flutter app at your Python (FastAPI) backend.
///
/// - Windows Desktop / Chrome web (backend on same PC) -> 'http://127.0.0.1:8000'
/// - Android Emulator                                  -> 'http://10.0.2.2:8000'
/// - Real phone (same Wi-Fi as your PC)                -> 'http://<PC-LAN-IP>:8000'
///   (find your PC's IP with "ipconfig" on Windows)
class ApiConfig {
  static const String baseUrl = 'http://192.168.100.46:8000'; // <-- REPLACE with your PC's real IP
}
