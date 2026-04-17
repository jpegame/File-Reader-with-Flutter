import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 👇 import tabelas
import 'tables/category.dart';
import 'tables/config.dart';
import 'tables/document.dart';
import 'tables/markup.dart';
import 'tables/notation.dart';

// 👇 import DAOS
import 'daos/category_dao.dart';
import 'daos/config_dao.dart';
import 'daos/document_dao.dart';
import 'daos/markup_dao.dart';
import 'daos/notation_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Category, Config, Document, Markup, Notation],
  daos: [CategoryDao, ConfigDao, DocumentDao, MarkupDao, NotationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}