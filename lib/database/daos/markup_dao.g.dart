// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markup_dao.dart';

// ignore_for_file: type=lint
mixin _$MarkupDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoryTable get category => attachedDatabase.category;
  $DocumentTable get document => attachedDatabase.document;
  $MarkupTable get markup => attachedDatabase.markup;
  MarkupDaoManager get managers => MarkupDaoManager(this);
}

class MarkupDaoManager {
  final _$MarkupDaoMixin _db;
  MarkupDaoManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db.attachedDatabase, _db.category);
  $$DocumentTableTableManager get document =>
      $$DocumentTableTableManager(_db.attachedDatabase, _db.document);
  $$MarkupTableTableManager get markup =>
      $$MarkupTableTableManager(_db.attachedDatabase, _db.markup);
}
