import 'package:drift/drift.dart';
import 'document.dart';

class Notation extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get page => integer()();
  IntColumn get posX => integer()();
  IntColumn get posY => integer()();
  IntColumn get documentId => integer().references(Document, #id)();
}
