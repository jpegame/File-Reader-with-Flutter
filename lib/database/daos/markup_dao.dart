import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/markup.dart';

part 'markup_dao.g.dart';

@DriftAccessor(tables: [Markup])
class MarkupDao extends DatabaseAccessor<AppDatabase> with _$MarkupDaoMixin {
  MarkupDao(AppDatabase db) : super(db);

  Stream<List<MarkupData>> watchMarkupsForDocument(int docId) => 
      (select(markup)..where((t) => t.documentId.equals(docId))).watch();
}