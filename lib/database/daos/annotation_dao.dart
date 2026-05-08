import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/annotation.dart';

part 'annotation_dao.g.dart';

@DriftAccessor(tables: [Annotation])
class AnnotationDao extends DatabaseAccessor<AppDatabase> with _$AnnotationDaoMixin {
  AnnotationDao(AppDatabase db) : super(db);

  Future<int> saveAnnotation(AnnotationCompanion entry) => into(annotation).insert(entry);

  Future<List<AnnotationData>> getAnnotationByPage(int docId, int page) {
    return (select(annotation)
          ..where((t) => t.documentId.equals(docId) & t.page.equals(page)))
        .get();
  }

  Future deleteAnnotation(int id) => (delete(annotation)..where((t) => t.id.equals(id))).go();
}