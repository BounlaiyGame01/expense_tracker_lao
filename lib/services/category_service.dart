import '../models/category_model.dart';

/// DEMO MODE: CategoryService keeps data in memory only (no MySQL/API).
/// Same public interface as the real version, so screens/AppState don't
/// need to change. Data resets every time the app restarts.
class CategoryService {
  static final List<CategoryModel> _store = [];
  static int _nextId = 1;

  Future<List<CategoryModel>> getAll() async {
    final list = List<CategoryModel>.from(_store);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<List<CategoryModel>> getByType(CategoryType type) async {
    return _store.where((c) => c.type == type).toList();
  }

  Future<int> add(CategoryModel category) async {
    final id = _nextId++;
    _store.add(CategoryModel(
      id: id,
      name: category.name,
      iconName: category.iconName,
      colorValue: category.colorValue,
      type: category.type,
    ));
    return id;
  }

  Future<int> update(CategoryModel category) async {
    final index = _store.indexWhere((c) => c.id == category.id);
    if (index != -1) _store[index] = category;
    return category.id!;
  }

  Future<int> delete(int id) async {
    _store.removeWhere((c) => c.id == id);
    return id;
  }

  /// Fills the in-memory store with the default category set the first
  /// time it's empty (mirrors what the real backend does on first run).
  Future<void> seedDefaultsIfEmpty() async {
    if (_store.isNotEmpty) return;
    for (final c in defaultCategories()) {
      await add(c);
    }
  }
}
