import 'package:drift/drift.dart';
import 'document.dart';

class Annotation extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(Document, #id)();
  IntColumn get page => integer()();
  TextColumn get type => text()();
  TextColumn get content => text().nullable()();
  TextColumn get rectsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}