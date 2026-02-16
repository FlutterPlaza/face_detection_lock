import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/face_template.dart';
import '../domain/face_template_store.dart';

/// Encrypted face template store backed by [FlutterSecureStorage].
///
/// Persists [FaceTemplate] objects across app restarts using the platform
/// keychain (iOS) or EncryptedSharedPreferences (Android).
///
/// Each template is stored as a JSON string under a namespaced key
/// (`face_tpl_<id>`). A separate index key tracks all stored template IDs.
///
/// ```dart
/// final store = SecureTemplateStore();
/// await store.save(template);
/// final all = await store.getAll();
/// ```
class SecureTemplateStore implements FaceTemplateStore {
  /// Creates a [SecureTemplateStore].
  ///
  /// An optional [storage] instance can be injected for testing.
  SecureTemplateStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'face_tpl_';
  static const _indexKey = 'face_tpl_index';

  String _templateKey(String id) => '$_keyPrefix$id';

  Future<Set<String>> _readIndex() async {
    final raw = await _storage.read(key: _indexKey);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as List).cast<String>().toSet();
  }

  Future<void> _writeIndex(Set<String> ids) async {
    await _storage.write(key: _indexKey, value: jsonEncode(ids.toList()));
  }

  @override
  Future<void> save(FaceTemplate template) async {
    final json = jsonEncode(template.toJson());
    await _storage.write(key: _templateKey(template.id), value: json);

    final index = await _readIndex();
    if (index.add(template.id)) {
      await _writeIndex(index);
    }
  }

  @override
  Future<FaceTemplate?> get(String id) async {
    final raw = await _storage.read(key: _templateKey(id));
    if (raw == null) return null;
    return FaceTemplate.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<FaceTemplate>> getAll() async {
    final index = await _readIndex();
    final templates = <FaceTemplate>[];
    for (final id in index) {
      final template = await get(id);
      if (template != null) {
        templates.add(template);
      }
    }
    return templates;
  }

  @override
  Future<void> delete(String id) async {
    await _storage.delete(key: _templateKey(id));

    final index = await _readIndex();
    if (index.remove(id)) {
      await _writeIndex(index);
    }
  }

  @override
  Future<void> clear() async {
    final index = await _readIndex();
    for (final id in index) {
      await _storage.delete(key: _templateKey(id));
    }
    await _storage.delete(key: _indexKey);
  }
}
