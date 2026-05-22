import 'package:drift/drift.dart';

import 'connection_stub.dart' 
  if (dart.library.ffi) 'connection_native.dart' 
  if (dart.library.js_interop) 'connection_web.dart';

// import tabelas
import 'tables/category.dart';
import 'tables/config.dart';
import 'tables/document.dart';
import 'tables/annotation.dart';

// import DAOS
import 'daos/category_dao.dart';
import 'daos/config_dao.dart';
import 'daos/document_dao.dart';
import 'daos/annotation_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Category, Config, Document, Annotation],
  daos: [CategoryDao, ConfigDao, DocumentDao, AnnotationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}