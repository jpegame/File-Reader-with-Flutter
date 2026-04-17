import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 👇 importa as tabelas
import 'tables/category.dart';
import 'tables/config.dart';
import 'tables/document.dart';
import 'tables/markup.dart';
import 'tables/notation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Category, Config, Document, Markup, Notation],
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