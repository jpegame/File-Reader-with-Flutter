import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/category.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Category])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Stream<List<CategoryData>> watchCategories() => select(category).watch();
  Future<int> insertCategory(String name) {
    return into(category).insert(
      CategoryCompanion.insert(name: name),
    );
  }
  Future deleteCategory(int id) => (delete(category)..where((t) => t.id.equals(id))).go();
}