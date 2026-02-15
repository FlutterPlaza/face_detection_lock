import 'face_template.dart';

/// Abstract storage interface for face templates.
///
/// Implement this to persist templates with your preferred backend
/// (SQLite, Hive, flutter_secure_storage, etc.).
abstract class FaceTemplateStore {
  /// Save or update a template.
  Future<void> save(FaceTemplate template);

  /// Retrieve a template by [id], or null if not found.
  Future<FaceTemplate?> get(String id);

  /// Retrieve all stored templates.
  Future<List<FaceTemplate>> getAll();

  /// Delete a template by [id].
  Future<void> delete(String id);

  /// Delete all stored templates.
  Future<void> clear();
}

/// In-memory template store. Data is lost when the app restarts.
///
/// Useful for testing or transient sessions.
class InMemoryTemplateStore implements FaceTemplateStore {
  final Map<String, FaceTemplate> _store = {};

  @override
  Future<void> save(FaceTemplate template) async {
    _store[template.id] = template;
  }

  @override
  Future<FaceTemplate?> get(String id) async => _store[id];

  @override
  Future<List<FaceTemplate>> getAll() async => _store.values.toList();

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
