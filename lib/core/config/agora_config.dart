import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraConfig {
  static String get appId {
    return dotenv.env['AGORA_APP_ID'] ?? '';
  }

  static String get appCertificate {
    return dotenv.env['AGORA_APP_CERTIFICATE'] ?? '';
  }

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? '';
  }
}
