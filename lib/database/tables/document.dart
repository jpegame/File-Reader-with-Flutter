import 'package:drift/drift.dart';
import 'category.dart';

class Document extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get lastAccess => dateTime()();
  IntColumn get lastPage => integer()();
  IntColumn get categoryId => integer().references(Category, #id)();
}
