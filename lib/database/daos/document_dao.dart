import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/document.dart';
import '../tables/category.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Document, Category])
class DocumentDao extends DatabaseAccessor<AppDatabase> with _$DocumentDaoMixin {
  DocumentDao(AppDatabase db) : super(db);

  // Get documents with their category info
  Stream<List<TypedResult>> watchDocumentsWithCategory() {
    return (select(document).join([
      innerJoin(category, category.id.equalsExp(document.categoryId)),
    ])).watch();
  }

  Future updateLastAccess(int docId) => 
      (update(document)..where((t) => t.id.equals(docId)))
      .write(DocumentCompanion(lastAccess: Value(DateTime.now())));

  Future<int> insertDocument(DocumentCompanion data) => into(document).insert(data);
}