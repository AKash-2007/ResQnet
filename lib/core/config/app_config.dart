enum Environment { development, staging, production }

class AppConfig {
  static const String appName = 'ResQnet';
  
  static Environment environment = Environment.development;
  
  // Toggle for Demo / Simulation Mode (Default is false for real-world mode)
  static bool demoMode = false;

  // Local development host & Cloudflare tunnel host
  static String? customServerHost;
  static const String defaultLanHost = '192.168.0.102:8000';
  static const String emulatorHost = '10.0.2.2:8000';
  static const String cloudflareHost = 'herbs-arrested-flex-pleased.trycloudflare.com';

  static String get activeHost => (customServerHost != null && customServerHost!.trim().isNotEmpty)
      ? customServerHost!.trim()
      : defaultLanHost;

  static bool get isSecure =>
      activeHost.startsWith('https://') ||
      activeHost.contains('.trycloudflare.com') ||
      activeHost.contains('.ngrok-free.app');

  static String get cleanHost {
    var host = activeHost;
    if (host.startsWith('https://')) {
      host = host.substring(8);
    } else if (host.startsWith('http://')) {
      host = host.substring(7);
    }
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    return host;
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        final scheme = isSecure ? 'https' : 'http';
        return '$scheme://$cleanHost/api/v1';
      case Environment.staging:
        return 'https://staging-api.resqnet.app/api/v1';
      case Environment.production:
        return 'https://api.resqnet.app/api/v1';
    }
  }

  static String get wsBaseUrl {
    switch (environment) {
      case Environment.development:
        final scheme = isSecure ? 'wss' : 'ws';
        return '$scheme://$cleanHost/api/v1/ws';
      case Environment.staging:
        return 'wss://staging-api.resqnet.app/api/v1/ws';
      case Environment.production:
        return 'wss://api.resqnet.app/api/v1/ws';
    }
  }

  // Configurable radius options in meters
  static const int defaultRadiusMeters = 1000;
  static const int compactRadiusMeters = 500;
}
