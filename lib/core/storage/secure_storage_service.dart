import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const _keyAccessToken = 'resqnet_access_token';
  static const _keyRefreshToken = 'resqnet_refresh_token';
  static const _keyUserId = 'resqnet_user_id';
  static const _keyLanguage = 'resqnet_language';
  static const _keyTheme = 'resqnet_theme';
  static const _keyAvailableToHelp = 'resqnet_available_to_help';
  static const _keyServerHost = 'resqnet_server_host';

  Future<void> saveServerHost(String host) async {
    await _storage.write(key: _keyServerHost, value: host);
  }

  Future<String?> getServerHost() async {
    return await _storage.read(key: _keyServerHost);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
  }

  Future<void> saveUserId(String id) async {
    await _storage.write(key: _keyUserId, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> saveLanguage(String langCode) async {
    await _storage.write(key: _keyLanguage, value: langCode);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: _keyLanguage);
  }

  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _keyTheme, value: mode);
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: _keyTheme);
  }

  Future<void> saveAvailableToHelp(bool available) async {
    await _storage.write(key: _keyAvailableToHelp, value: available.toString());
  }

  Future<bool> getAvailableToHelp() async {
    final val = await _storage.read(key: _keyAvailableToHelp);
    return val == 'true';
  }
}
