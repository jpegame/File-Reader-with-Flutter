import 'package:drift/drift.dart';
import 'document.dart';

class Markup extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get page => integer()();
  IntColumn get documentId => integer().references(Document, #id)();
}
