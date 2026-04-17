import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/notation.dart';

part 'notation_dao.g.dart';

@DriftAccessor(tables: [Notation])
class NotationDao extends DatabaseAccessor<AppDatabase> with _$NotationDaoMixin {
  NotationDao(AppDatabase db) : super(db);

  Stream<List<NotationData>> watchNotationsByPage(int docId, int page) => 
      (select(notation)..where((t) => t.documentId.equals(docId) & t.page.equals(page))).watch();
}