import 'package:flutter/services.dart' show rootBundle;

/// Centralized Environment Configuration
/// Reads from loaded environment variables (e.g. from .env file or default fallbacks)
/// so no sensitive keys or passwords are hardcoded in the application.
class AppEnv {
  static final Map<String, String> _env = {};

  /// Loads .env file if available in assets / bundle, otherwise uses compile-time / runtime defaults
  static Future<void> init() async {
    try {
      final envString = await rootBundle.loadString('.env');
      for (final line in envString.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final separatorIndex = trimmed.indexOf('=');
        if (separatorIndex > 0) {
          final key = trimmed.substring(0, separatorIndex).trim();
          final val = trimmed.substring(separatorIndex + 1).trim();
          _env[key] = val;
        }
      }
    } catch (_) {
      // .env not bundled or running without asset; defaults will be used
    }
  }

  static String get(String key, {String fallback = ''}) {
    return _env[key] ?? fallback;
  }

  // Admin Auth Config
  static String get adminUsername => get('ADMIN_USERNAME', fallback: 'admin');
  static String get adminPassword => get('ADMIN_PASSWORD', fallback: 'admin@123');
  static String get adminEmail => get('ADMIN_EMAIL', fallback: 'admin@stitchup.com');

  // Tailor defaults
  static String get defaultTailorId => get('DEFAULT_TAILOR_ID', fallback: 'admin_studio_01');
  static String get defaultShopName => get('DEFAULT_SHOP_NAME', fallback: 'Mali Tailor');
  static String get defaultOwnerName => get('DEFAULT_OWNER_NAME', fallback: 'Mahadev Mali');
  static String get defaultPhone => get('DEFAULT_PHONE', fallback: '+91 99609 45720');
  static double get defaultShirtWage =>
      double.tryParse(get('DEFAULT_SHIRT_WAGE', fallback: '130')) ?? 130.0;
  static double get defaultPantWage =>
      double.tryParse(get('DEFAULT_PANT_WAGE', fallback: '150')) ?? 150.0;
}
