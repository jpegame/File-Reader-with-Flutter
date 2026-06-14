import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/document.dart';
import '../tables/category.dart';

part 'document_dao.g.dart';

enum DocumentSortOption { lastAccess, name }

@DriftAccessor(tables: [Document, Category])
class DocumentDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentDaoMixin {
  DocumentDao(AppDatabase db) : super(db);

  Stream<List<TypedResult>> watchDocumentsWithCategory({
    int? categoryId,
    DocumentSortOption sortBy = DocumentSortOption.lastAccess,
  }) {
    final query = select(
      document,
    ).join([innerJoin(category, category.id.equalsExp(document.categoryId))]);

    if (categoryId != null) {
      query.where(document.categoryId.equals(categoryId));
    }

    query.orderBy([
      if (sortBy == DocumentSortOption.name)
        OrderingTerm.asc(document.name)
      else
        OrderingTerm.desc(document.lastAccess),
    ]);

    return query.watch();
  }

  Future<int> deleteDocument(int docId) {
    return (delete(document)..where((t) => t.id.equals(docId))).go();
  }

  Future updateLastAccess(int docId) =>
      (update(document)..where((t) => t.id.equals(docId))).write(
        DocumentCompanion(lastAccess: Value(DateTime.now())),
      );

  Future<int> insertDocument({
    required String name,
    required int categoryId,
    String? filePath,
    Uint8List? fileData,
  }) {
    return into(document).insert(
      DocumentCompanion.insert(
        name: name,
        categoryId: categoryId,
        filePath: Value(filePath),
        fileData: Value(fileData),
        lastAccess: DateTime.now(),
        lastPage: 0,
      ),
    );
  }
}
