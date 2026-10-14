import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../network/auth_interceptor.dart';

/// Secure local file storage service using AES-256-GCM authenticated encryption,
/// atomic file writes, per-user namespacing, and corruption recovery.
class LocalStorageService {
  final FlutterSecureStorage _secureStorage;
  final Directory? _overrideDirectory;

  enc.Key? _masterKey;
  Directory? _storageDir;
  bool _isInitialized = false;

  static const String masterKeyStorageKey = 'diba_storage_master_key_v1';

  LocalStorageService(
    this._secureStorage, {
    Directory? overrideDirectory,
  }) : _overrideDirectory = overrideDirectory;

  /// Ensures master key and storage directory are loaded and ready.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Resolve or generate 256-bit AES Master Key
    String? base64Key;
    try {
      base64Key = await _secureStorage.read(key: masterKeyStorageKey);
    } catch (e) {
      debugPrint('[LocalStorageService] KeyStore read failure: $e');
    }

    if (base64Key == null || base64Key.isEmpty) {
      final newKey = enc.Key.fromSecureRandom(32);
      base64Key = newKey.base64;
      try {
        await _secureStorage.write(
          key: masterKeyStorageKey,
          value: base64Key,
        );
      } catch (e) {
        debugPrint('[LocalStorageService] KeyStore write failure: $e');
      }
      _masterKey = newKey;
    } else {
      _masterKey = enc.Key.fromBase64(base64Key);
    }

    // 2. Resolve storage directory
    if (_overrideDirectory != null) {
      _storageDir = _overrideDirectory;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      _storageDir = Directory('${appDocDir.path}/diba_secure_vault');
    }

    if (!await _storageDir!.exists()) {
      await _storageDir!.create(recursive: true);
    } else {
      // Clean up any stale .tmp files from previous unexpected app kill/crash
      try {
        final entries = _storageDir!.listSync();
        for (final entry in entries) {
          if (entry is File && entry.path.endsWith('.tmp')) {
            entry.deleteSync();
          }
        }
      } catch (_) {}
    }

    _isInitialized = true;
  }

  File _resolveFile(String key, String? userId) {
    final sanitizedUser = (userId != null && userId.isNotEmpty)
        ? userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        : 'global';
    final sanitizedKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = 'usr_${sanitizedUser}_$sanitizedKey.enc';
    return File('${_storageDir!.path}/$filename');
  }

  /// Writes JSON data atomikally with AES-256-GCM encryption.
  Future<void> writeEncryptedJson(
    String key,
    dynamic data, {
    String? userId,
  }) async {
    await initialize();

    final targetFile = _resolveFile(key, userId);
    final tmpFile = File('${targetFile.path}.tmp');

    try {
      final jsonPlaintext = jsonEncode(data);

      // NIST SP 800-38D: 12-byte (96-bit) IV is the standard recommended nonce for AES-GCM
      // Directly processed by GHASH without reduction, optimal performance and security.
      final iv = enc.IV.fromSecureRandom(12);
      final encrypter = enc.Encrypter(enc.AES(_masterKey!, mode: enc.AESMode.gcm));

      final encrypted = encrypter.encrypt(jsonPlaintext, iv: iv);

      // Payload format: [Base64 12-byte IV]:[Base64 Ciphertext + 16-byte Auth Tag]
      final fileContent = '${iv.base64}:${encrypted.base64}';

      // Atomic write: write to .tmp, flush to storage, then atomic rename
      await tmpFile.writeAsString(fileContent, flush: true);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tmpFile.rename(targetFile.path);
    } catch (e) {
      // Clean up tmp file if write or encryption failed
      if (await tmpFile.exists()) {
        await tmpFile.delete().catchError((_) => tmpFile);
      }
      debugPrint('[LocalStorageService] Error writing encrypted file $key: $e');
      rethrow;
    }
  }

  /// Reads and decrypts JSON data. Recovers gracefully if file is corrupted.
  Future<dynamic> readEncryptedJson(
    String key, {
    String? userId,
  }) async {
    await initialize();

    final file = _resolveFile(key, userId);
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      if (content.isEmpty || !content.contains(':')) {
        throw const FormatException('Invalid storage payload format');
      }

      final parts = content.split(':');
      if (parts.length != 2) {
        throw const FormatException('Malformed payload split');
      }

      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);

      final encrypter = enc.Encrypter(enc.AES(_masterKey!, mode: enc.AESMode.gcm));
      final decryptedJson = encrypter.decrypt(encrypted, iv: iv);

      return jsonDecode(decryptedJson);
    } catch (e) {
      debugPrint('[LocalStorageService] Decryption or integrity check failed for $key: $e');
      // Corruption recovery: Quarantine corrupted file to avoid repeated parse crashes
      try {
        final corruptFile = File(
          '${file.path}.corrupt.${DateTime.now().millisecondsSinceEpoch}',
        );
        await file.rename(corruptFile.path);
      } catch (_) {}
      return null;
    }
  }

  /// Deletes an encrypted file.
  Future<bool> deleteEncrypted(
    String key, {
    String? userId,
  }) async {
    await initialize();
    final file = _resolveFile(key, userId);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// Clears cache files belonging to a specific user, optionally preserving pending queue.
  Future<void> clearUserCache(
    String userId, {
    bool preservePendingQueue = true,
  }) async {
    await initialize();
    if (!await _storageDir!.exists()) return;

    final sanitizedUser = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final prefix = 'usr_${sanitizedUser}_';

    final files = _storageDir!.listSync();
    for (final entity in files) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (name.startsWith(prefix)) {
          if (preservePendingQueue && name.contains('pending_sync_queue')) {
            continue; // Keep unsynced queue so patient records are never lost
          }
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    }
  }

  /// Returns last modified timestamp of the encrypted file.
  Future<DateTime?> getLastModified(
    String key, {
    String? userId,
  }) async {
    await initialize();
    final file = _resolveFile(key, userId);
    if (await file.exists()) {
      return file.lastModified();
    }
    return null;
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return LocalStorageService(secureStorage);
});
