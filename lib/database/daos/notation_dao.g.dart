// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notation_dao.dart';

// ignore_for_file: type=lint
mixin _$NotationDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoryTable get category => attachedDatabase.category;
  $DocumentTable get document => attachedDatabase.document;
  $NotationTable get notation => attachedDatabase.notation;
  NotationDaoManager get managers => NotationDaoManager(this);
}

class NotationDaoManager {
  final _$NotationDaoMixin _db;
  NotationDaoManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db.attachedDatabase, _db.category);
  $$DocumentTableTableManager get document =>
      $$DocumentTableTableManager(_db.attachedDatabase, _db.document);
  $$NotationTableTableManager get notation =>
      $$NotationTableTableManager(_db.attachedDatabase, _db.notation);
}
