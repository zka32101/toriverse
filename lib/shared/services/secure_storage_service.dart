import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data (auth tokens, credentials)
/// Uses platform-native secure storage:
/// - iOS: Keychain
/// - Android: AndroidKeyStore
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  late final FlutterSecureStorage _storage;

  SecureStorageService() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        // Use default KeyStore encryption for Android
        keyCipherAlgorithm:
            KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        // Use Keychain for iOS with default settings
        accessibility: KeychainAccessibility.first_this_device_this_device_only,
      ),
    );
  }

  /// Save authentication token securely
  /// [token] - JWT or auth token from Firebase Auth
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('[SecureStorage] Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error saving token: $e');
      }
      rethrow;
    }
  }

  /// Retrieve authentication token
  /// Returns null if no token found
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (kDebugMode && token != null) {
        print('[SecureStorage] Token retrieved (length: ${token.length})');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error retrieving token: $e');
      }
      return null;
    }
  }

  /// Save refresh token
  /// Used for obtaining new access tokens
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      if (kDebugMode) {
        print('[SecureStorage] Refresh token saved');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error saving refresh token: $e');
      }
      rethrow;
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error retrieving refresh token: $e');
      }
      return null;
    }
  }

  /// Save user ID
  /// Used for identifying user across sessions
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      if (kDebugMode) {
        print('[SecureStorage] User ID saved');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error saving user ID: $e');
      }
      rethrow;
    }
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error retrieving user ID: $e');
      }
      return null;
    }
  }

  /// Delete authentication token (logout)
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      if (kDebugMode) {
        print('[SecureStorage] Token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error deleting token: $e');
      }
      rethrow;
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error deleting refresh token: $e');
      }
    }
  }

  /// Delete user ID
  Future<void> deleteUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error deleting user ID: $e');
      }
    }
  }

  /// Clear all stored data (complete logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        print('[SecureStorage] All data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error clearing storage: $e');
      }
      rethrow;
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all keys (debug only)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('[SecureStorage] Error reading all: $e');
      }
      return {};
    }
  }
}

/// Riverpod provider for SecureStorageService
/// Usage: ref.watch(secureStorageProvider)
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider((ref) {
  return SecureStorageService();
});
