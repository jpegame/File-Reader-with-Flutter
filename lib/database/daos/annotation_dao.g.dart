// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation_dao.dart';

// ignore_for_file: type=lint
mixin _$AnnotationDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoryTable get category => attachedDatabase.category;
  $DocumentTable get document => attachedDatabase.document;
  $AnnotationTable get annotation => attachedDatabase.annotation;
  AnnotationDaoManager get managers => AnnotationDaoManager(this);
}

class AnnotationDaoManager {
  final _$AnnotationDaoMixin _db;
  AnnotationDaoManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db.attachedDatabase, _db.category);
  $$DocumentTableTableManager get document =>
      $$DocumentTableTableManager(_db.attachedDatabase, _db.document);
  $$AnnotationTableTableManager get annotation =>
      $$AnnotationTableTableManager(_db.attachedDatabase, _db.annotation);
}
