// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoryTable extends Category
    with TableInfo<$CategoryTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CategoryTable createAlias(String alias) {
    return $CategoryTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  const CategoryData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoryCompanion toCompanion(bool nullToAbsent) {
    return CategoryCompanion(id: Value(id), name: Value(name));
  }

  factory CategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryData copyWith({int? id, String? name}) =>
      CategoryData(id: id ?? this.id, name: name ?? this.name);
  CategoryData copyWithCompanion(CategoryCompanion data) {
    return CategoryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData && other.id == this.id && other.name == this.name);
}

class CategoryCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  const CategoryCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoryCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoryCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoryCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ConfigTable extends Config with TableInfo<$ConfigTable, ConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ConfigTable createAlias(String alias) {
    return $ConfigTable(attachedDatabase, alias);
  }
}

class ConfigData extends DataClass implements Insertable<ConfigData> {
  final int id;
  final String key;
  final String value;
  const ConfigData({required this.id, required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  ConfigCompanion toCompanion(bool nullToAbsent) {
    return ConfigCompanion(id: Value(id), key: Value(key), value: Value(value));
  }

  factory ConfigData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigData(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  ConfigData copyWith({int? id, String? key, String? value}) => ConfigData(
    id: id ?? this.id,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  ConfigData copyWithCompanion(ConfigCompanion data) {
    return ConfigData(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigData(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigData &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value);
}

class ConfigCompanion extends UpdateCompanion<ConfigData> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  const ConfigCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  ConfigCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
  }) : key = Value(key),
       value = Value(value);
  static Insertable<ConfigData> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  ConfigCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? value,
  }) {
    return ConfigCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $DocumentTable extends Document
    with TableInfo<$DocumentTable, DocumentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessMeta = const VerificationMeta(
    'lastAccess',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccess = GeneratedColumn<DateTime>(
    'last_access',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES category (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    lastAccess,
    lastPage,
    categoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_access')) {
      context.handle(
        _lastAccessMeta,
        lastAccess.isAcceptableOrUnknown(data['last_access']!, _lastAccessMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAccessMeta);
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    } else if (isInserting) {
      context.missing(_lastPageMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_access'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $DocumentTable createAlias(String alias) {
    return $DocumentTable(attachedDatabase, alias);
  }
}

class DocumentData extends DataClass implements Insertable<DocumentData> {
  final int id;
  final String name;
  final DateTime lastAccess;
  final int lastPage;
  final int categoryId;
  const DocumentData({
    required this.id,
    required this.name,
    required this.lastAccess,
    required this.lastPage,
    required this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['last_access'] = Variable<DateTime>(lastAccess);
    map['last_page'] = Variable<int>(lastPage);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  DocumentCompanion toCompanion(bool nullToAbsent) {
    return DocumentCompanion(
      id: Value(id),
      name: Value(name),
      lastAccess: Value(lastAccess),
      lastPage: Value(lastPage),
      categoryId: Value(categoryId),
    );
  }

  factory DocumentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastAccess: serializer.fromJson<DateTime>(json['lastAccess']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lastAccess': serializer.toJson<DateTime>(lastAccess),
      'lastPage': serializer.toJson<int>(lastPage),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  DocumentData copyWith({
    int? id,
    String? name,
    DateTime? lastAccess,
    int? lastPage,
    int? categoryId,
  }) => DocumentData(
    id: id ?? this.id,
    name: name ?? this.name,
    lastAccess: lastAccess ?? this.lastAccess,
    lastPage: lastPage ?? this.lastPage,
    categoryId: categoryId ?? this.categoryId,
  );
  DocumentData copyWithCompanion(DocumentCompanion data) {
    return DocumentData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastAccess: data.lastAccess.present
          ? data.lastAccess.value
          : this.lastAccess,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastAccess: $lastAccess, ')
          ..write('lastPage: $lastPage, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastAccess, lastPage, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentData &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastAccess == this.lastAccess &&
          other.lastPage == this.lastPage &&
          other.categoryId == this.categoryId);
}

class DocumentCompanion extends UpdateCompanion<DocumentData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> lastAccess;
  final Value<int> lastPage;
  final Value<int> categoryId;
  const DocumentCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastAccess = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  DocumentCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime lastAccess,
    required int lastPage,
    required int categoryId,
  }) : name = Value(name),
       lastAccess = Value(lastAccess),
       lastPage = Value(lastPage),
       categoryId = Value(categoryId);
  static Insertable<DocumentData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? lastAccess,
    Expression<int>? lastPage,
    Expression<int>? categoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastAccess != null) 'last_access': lastAccess,
      if (lastPage != null) 'last_page': lastPage,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  DocumentCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? lastAccess,
    Value<int>? lastPage,
    Value<int>? categoryId,
  }) {
    return DocumentCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastAccess: lastAccess ?? this.lastAccess,
      lastPage: lastPage ?? this.lastPage,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastAccess.present) {
      map['last_access'] = Variable<DateTime>(lastAccess.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastAccess: $lastAccess, ')
          ..write('lastPage: $lastPage, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }
}

class $MarkupTable extends Markup with TableInfo<$MarkupTable, MarkupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarkupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, content, page, documentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'markup';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarkupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarkupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarkupData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
    );
  }

  @override
  $MarkupTable createAlias(String alias) {
    return $MarkupTable(attachedDatabase, alias);
  }
}

class MarkupData extends DataClass implements Insertable<MarkupData> {
  final int id;
  final String content;
  final int page;
  final int documentId;
  const MarkupData({
    required this.id,
    required this.content,
    required this.page,
    required this.documentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['page'] = Variable<int>(page);
    map['document_id'] = Variable<int>(documentId);
    return map;
  }

  MarkupCompanion toCompanion(bool nullToAbsent) {
    return MarkupCompanion(
      id: Value(id),
      content: Value(content),
      page: Value(page),
      documentId: Value(documentId),
    );
  }

  factory MarkupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarkupData(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      page: serializer.fromJson<int>(json['page']),
      documentId: serializer.fromJson<int>(json['documentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'page': serializer.toJson<int>(page),
      'documentId': serializer.toJson<int>(documentId),
    };
  }

  MarkupData copyWith({int? id, String? content, int? page, int? documentId}) =>
      MarkupData(
        id: id ?? this.id,
        content: content ?? this.content,
        page: page ?? this.page,
        documentId: documentId ?? this.documentId,
      );
  MarkupData copyWithCompanion(MarkupCompanion data) {
    return MarkupData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      page: data.page.present ? data.page.value : this.page,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarkupData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('page: $page, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, page, documentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkupData &&
          other.id == this.id &&
          other.content == this.content &&
          other.page == this.page &&
          other.documentId == this.documentId);
}

class MarkupCompanion extends UpdateCompanion<MarkupData> {
  final Value<int> id;
  final Value<String> content;
  final Value<int> page;
  final Value<int> documentId;
  const MarkupCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.page = const Value.absent(),
    this.documentId = const Value.absent(),
  });
  MarkupCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    required int page,
    required int documentId,
  }) : content = Value(content),
       page = Value(page),
       documentId = Value(documentId);
  static Insertable<MarkupData> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<int>? page,
    Expression<int>? documentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (page != null) 'page': page,
      if (documentId != null) 'document_id': documentId,
    });
  }

  MarkupCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<int>? page,
    Value<int>? documentId,
  }) {
    return MarkupCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      page: page ?? this.page,
      documentId: documentId ?? this.documentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarkupCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('page: $page, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }
}

class $NotationTable extends Notation
    with TableInfo<$NotationTable, NotationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<int> posX = GeneratedColumn<int>(
    'pos_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<int> posY = GeneratedColumn<int>(
    'pos_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    page,
    posX,
    posY,
    documentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notation';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
        _posXMeta,
        posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta),
      );
    } else if (isInserting) {
      context.missing(_posXMeta);
    }
    if (data.containsKey('pos_y')) {
      context.handle(
        _posYMeta,
        posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta),
      );
    } else if (isInserting) {
      context.missing(_posYMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotationData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      posX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_x'],
      )!,
      posY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_y'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
    );
  }

  @override
  $NotationTable createAlias(String alias) {
    return $NotationTable(attachedDatabase, alias);
  }
}

class NotationData extends DataClass implements Insertable<NotationData> {
  final int id;
  final String content;
  final int page;
  final int posX;
  final int posY;
  final int documentId;
  const NotationData({
    required this.id,
    required this.content,
    required this.page,
    required this.posX,
    required this.posY,
    required this.documentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['page'] = Variable<int>(page);
    map['pos_x'] = Variable<int>(posX);
    map['pos_y'] = Variable<int>(posY);
    map['document_id'] = Variable<int>(documentId);
    return map;
  }

  NotationCompanion toCompanion(bool nullToAbsent) {
    return NotationCompanion(
      id: Value(id),
      content: Value(content),
      page: Value(page),
      posX: Value(posX),
      posY: Value(posY),
      documentId: Value(documentId),
    );
  }

  factory NotationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotationData(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      page: serializer.fromJson<int>(json['page']),
      posX: serializer.fromJson<int>(json['posX']),
      posY: serializer.fromJson<int>(json['posY']),
      documentId: serializer.fromJson<int>(json['documentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'page': serializer.toJson<int>(page),
      'posX': serializer.toJson<int>(posX),
      'posY': serializer.toJson<int>(posY),
      'documentId': serializer.toJson<int>(documentId),
    };
  }

  NotationData copyWith({
    int? id,
    String? content,
    int? page,
    int? posX,
    int? posY,
    int? documentId,
  }) => NotationData(
    id: id ?? this.id,
    content: content ?? this.content,
    page: page ?? this.page,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    documentId: documentId ?? this.documentId,
  );
  NotationData copyWithCompanion(NotationCompanion data) {
    return NotationData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      page: data.page.present ? data.page.value : this.page,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotationData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('page: $page, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, page, posX, posY, documentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotationData &&
          other.id == this.id &&
          other.content == this.content &&
          other.page == this.page &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.documentId == this.documentId);
}

class NotationCompanion extends UpdateCompanion<NotationData> {
  final Value<int> id;
  final Value<String> content;
  final Value<int> page;
  final Value<int> posX;
  final Value<int> posY;
  final Value<int> documentId;
  const NotationCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.page = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.documentId = const Value.absent(),
  });
  NotationCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    required int page,
    required int posX,
    required int posY,
    required int documentId,
  }) : content = Value(content),
       page = Value(page),
       posX = Value(posX),
       posY = Value(posY),
       documentId = Value(documentId);
  static Insertable<NotationData> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<int>? page,
    Expression<int>? posX,
    Expression<int>? posY,
    Expression<int>? documentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (page != null) 'page': page,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (documentId != null) 'document_id': documentId,
    });
  }

  NotationCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<int>? page,
    Value<int>? posX,
    Value<int>? posY,
    Value<int>? documentId,
  }) {
    return NotationCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      page: page ?? this.page,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      documentId: documentId ?? this.documentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<int>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<int>(posY.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotationCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('page: $page, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoryTable category = $CategoryTable(this);
  late final $ConfigTable config = $ConfigTable(this);
  late final $DocumentTable document = $DocumentTable(this);
  late final $MarkupTable markup = $MarkupTable(this);
  late final $NotationTable notation = $NotationTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    category,
    config,
    document,
    markup,
    notation,
  ];
}

typedef $$CategoryTableCreateCompanionBuilder =
    CategoryCompanion Function({Value<int> id, required String name});
typedef $$CategoryTableUpdateCompanionBuilder =
    CategoryCompanion Function({Value<int> id, Value<String> name});

final class $$CategoryTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryTable, CategoryData> {
  $$CategoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DocumentTable, List<DocumentData>>
  _documentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.document,
    aliasName: $_aliasNameGenerator(db.category.id, db.document.categoryId),
  );

  $$DocumentTableProcessedTableManager get documentRefs {
    final manager = $$DocumentTableTableManager(
      $_db,
      $_db.document,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoryTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentRefs(
    Expression<bool> Function($$DocumentTableFilterComposer f) f,
  ) {
    final $$DocumentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableFilterComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryTable> {
  $$CategoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> documentRefs<T extends Object>(
    Expression<T> Function($$DocumentTableAnnotationComposer a) f,
  ) {
    final $$DocumentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableAnnotationComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryTable,
          CategoryData,
          $$CategoryTableFilterComposer,
          $$CategoryTableOrderingComposer,
          $$CategoryTableAnnotationComposer,
          $$CategoryTableCreateCompanionBuilder,
          $$CategoryTableUpdateCompanionBuilder,
          (CategoryData, $$CategoryTableReferences),
          CategoryData,
          PrefetchHooks Function({bool documentRefs})
        > {
  $$CategoryTableTableManager(_$AppDatabase db, $CategoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CategoryCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CategoryCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentRefs) db.document],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentRefs)
                    await $_getPrefetchedData<
                      CategoryData,
                      $CategoryTable,
                      DocumentData
                    >(
                      currentTable: table,
                      referencedTable: $$CategoryTableReferences
                          ._documentRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoryTableReferences(db, table, p0).documentRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryTable,
      CategoryData,
      $$CategoryTableFilterComposer,
      $$CategoryTableOrderingComposer,
      $$CategoryTableAnnotationComposer,
      $$CategoryTableCreateCompanionBuilder,
      $$CategoryTableUpdateCompanionBuilder,
      (CategoryData, $$CategoryTableReferences),
      CategoryData,
      PrefetchHooks Function({bool documentRefs})
    >;
typedef $$ConfigTableCreateCompanionBuilder =
    ConfigCompanion Function({
      Value<int> id,
      required String key,
      required String value,
    });
typedef $$ConfigTableUpdateCompanionBuilder =
    ConfigCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> value,
    });

class $$ConfigTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigTable> {
  $$ConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigTable> {
  $$ConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigTable> {
  $$ConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigTable,
          ConfigData,
          $$ConfigTableFilterComposer,
          $$ConfigTableOrderingComposer,
          $$ConfigTableAnnotationComposer,
          $$ConfigTableCreateCompanionBuilder,
          $$ConfigTableUpdateCompanionBuilder,
          (ConfigData, BaseReferences<_$AppDatabase, $ConfigTable, ConfigData>),
          ConfigData,
          PrefetchHooks Function()
        > {
  $$ConfigTableTableManager(_$AppDatabase db, $ConfigTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => ConfigCompanion(id: id, key: key, value: value),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String value,
              }) => ConfigCompanion.insert(id: id, key: key, value: value),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigTable,
      ConfigData,
      $$ConfigTableFilterComposer,
      $$ConfigTableOrderingComposer,
      $$ConfigTableAnnotationComposer,
      $$ConfigTableCreateCompanionBuilder,
      $$ConfigTableUpdateCompanionBuilder,
      (ConfigData, BaseReferences<_$AppDatabase, $ConfigTable, ConfigData>),
      ConfigData,
      PrefetchHooks Function()
    >;
typedef $$DocumentTableCreateCompanionBuilder =
    DocumentCompanion Function({
      Value<int> id,
      required String name,
      required DateTime lastAccess,
      required int lastPage,
      required int categoryId,
    });
typedef $$DocumentTableUpdateCompanionBuilder =
    DocumentCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> lastAccess,
      Value<int> lastPage,
      Value<int> categoryId,
    });

final class $$DocumentTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentTable, DocumentData> {
  $$DocumentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoryTable _categoryIdTable(_$AppDatabase db) =>
      db.category.createAlias(
        $_aliasNameGenerator(db.document.categoryId, db.category.id),
      );

  $$CategoryTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoryTableTableManager(
      $_db,
      $_db.category,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MarkupTable, List<MarkupData>> _markupRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.markup,
    aliasName: $_aliasNameGenerator(db.document.id, db.markup.documentId),
  );

  $$MarkupTableProcessedTableManager get markupRefs {
    final manager = $$MarkupTableTableManager(
      $_db,
      $_db.markup,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_markupRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotationTable, List<NotationData>>
  _notationRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notation,
    aliasName: $_aliasNameGenerator(db.document.id, db.notation.documentId),
  );

  $$NotationTableProcessedTableManager get notationRefs {
    final manager = $$NotationTableTableManager(
      $_db,
      $_db.notation,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notationRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentTable> {
  $$DocumentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccess => $composableBuilder(
    column: $table.lastAccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryTableFilterComposer get categoryId {
    final $$CategoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.category,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryTableFilterComposer(
            $db: $db,
            $table: $db.category,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> markupRefs(
    Expression<bool> Function($$MarkupTableFilterComposer f) f,
  ) {
    final $$MarkupTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markup,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkupTableFilterComposer(
            $db: $db,
            $table: $db.markup,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notationRefs(
    Expression<bool> Function($$NotationTableFilterComposer f) f,
  ) {
    final $$NotationTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notation,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotationTableFilterComposer(
            $db: $db,
            $table: $db.notation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentTable> {
  $$DocumentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccess => $composableBuilder(
    column: $table.lastAccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryTableOrderingComposer get categoryId {
    final $$CategoryTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.category,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryTableOrderingComposer(
            $db: $db,
            $table: $db.category,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentTable> {
  $$DocumentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccess => $composableBuilder(
    column: $table.lastAccess,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  $$CategoryTableAnnotationComposer get categoryId {
    final $$CategoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.category,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryTableAnnotationComposer(
            $db: $db,
            $table: $db.category,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> markupRefs<T extends Object>(
    Expression<T> Function($$MarkupTableAnnotationComposer a) f,
  ) {
    final $$MarkupTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.markup,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarkupTableAnnotationComposer(
            $db: $db,
            $table: $db.markup,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notationRefs<T extends Object>(
    Expression<T> Function($$NotationTableAnnotationComposer a) f,
  ) {
    final $$NotationTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notation,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotationTableAnnotationComposer(
            $db: $db,
            $table: $db.notation,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentTable,
          DocumentData,
          $$DocumentTableFilterComposer,
          $$DocumentTableOrderingComposer,
          $$DocumentTableAnnotationComposer,
          $$DocumentTableCreateCompanionBuilder,
          $$DocumentTableUpdateCompanionBuilder,
          (DocumentData, $$DocumentTableReferences),
          DocumentData,
          PrefetchHooks Function({
            bool categoryId,
            bool markupRefs,
            bool notationRefs,
          })
        > {
  $$DocumentTableTableManager(_$AppDatabase db, $DocumentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> lastAccess = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
              }) => DocumentCompanion(
                id: id,
                name: name,
                lastAccess: lastAccess,
                lastPage: lastPage,
                categoryId: categoryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime lastAccess,
                required int lastPage,
                required int categoryId,
              }) => DocumentCompanion.insert(
                id: id,
                name: name,
                lastAccess: lastAccess,
                lastPage: lastPage,
                categoryId: categoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, markupRefs = false, notationRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (markupRefs) db.markup,
                    if (notationRefs) db.notation,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$DocumentTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$DocumentTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (markupRefs)
                        await $_getPrefetchedData<
                          DocumentData,
                          $DocumentTable,
                          MarkupData
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentTableReferences
                              ._markupRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentTableReferences(
                                db,
                                table,
                                p0,
                              ).markupRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notationRefs)
                        await $_getPrefetchedData<
                          DocumentData,
                          $DocumentTable,
                          NotationData
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentTableReferences
                              ._notationRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentTableReferences(
                                db,
                                table,
                                p0,
                              ).notationRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentTable,
      DocumentData,
      $$DocumentTableFilterComposer,
      $$DocumentTableOrderingComposer,
      $$DocumentTableAnnotationComposer,
      $$DocumentTableCreateCompanionBuilder,
      $$DocumentTableUpdateCompanionBuilder,
      (DocumentData, $$DocumentTableReferences),
      DocumentData,
      PrefetchHooks Function({
        bool categoryId,
        bool markupRefs,
        bool notationRefs,
      })
    >;
typedef $$MarkupTableCreateCompanionBuilder =
    MarkupCompanion Function({
      Value<int> id,
      required String content,
      required int page,
      required int documentId,
    });
typedef $$MarkupTableUpdateCompanionBuilder =
    MarkupCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<int> page,
      Value<int> documentId,
    });

final class $$MarkupTableReferences
    extends BaseReferences<_$AppDatabase, $MarkupTable, MarkupData> {
  $$MarkupTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentTable _documentIdTable(_$AppDatabase db) => db.document
      .createAlias($_aliasNameGenerator(db.markup.documentId, db.document.id));

  $$DocumentTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentTableTableManager(
      $_db,
      $_db.document,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MarkupTableFilterComposer
    extends Composer<_$AppDatabase, $MarkupTable> {
  $$MarkupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentTableFilterComposer get documentId {
    final $$DocumentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableFilterComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkupTableOrderingComposer
    extends Composer<_$AppDatabase, $MarkupTable> {
  $$MarkupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentTableOrderingComposer get documentId {
    final $$DocumentTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableOrderingComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkupTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarkupTable> {
  $$MarkupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  $$DocumentTableAnnotationComposer get documentId {
    final $$DocumentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableAnnotationComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarkupTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarkupTable,
          MarkupData,
          $$MarkupTableFilterComposer,
          $$MarkupTableOrderingComposer,
          $$MarkupTableAnnotationComposer,
          $$MarkupTableCreateCompanionBuilder,
          $$MarkupTableUpdateCompanionBuilder,
          (MarkupData, $$MarkupTableReferences),
          MarkupData,
          PrefetchHooks Function({bool documentId})
        > {
  $$MarkupTableTableManager(_$AppDatabase db, $MarkupTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarkupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarkupTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarkupTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> documentId = const Value.absent(),
              }) => MarkupCompanion(
                id: id,
                content: content,
                page: page,
                documentId: documentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                required int page,
                required int documentId,
              }) => MarkupCompanion.insert(
                id: id,
                content: content,
                page: page,
                documentId: documentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MarkupTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$MarkupTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$MarkupTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MarkupTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarkupTable,
      MarkupData,
      $$MarkupTableFilterComposer,
      $$MarkupTableOrderingComposer,
      $$MarkupTableAnnotationComposer,
      $$MarkupTableCreateCompanionBuilder,
      $$MarkupTableUpdateCompanionBuilder,
      (MarkupData, $$MarkupTableReferences),
      MarkupData,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$NotationTableCreateCompanionBuilder =
    NotationCompanion Function({
      Value<int> id,
      required String content,
      required int page,
      required int posX,
      required int posY,
      required int documentId,
    });
typedef $$NotationTableUpdateCompanionBuilder =
    NotationCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<int> page,
      Value<int> posX,
      Value<int> posY,
      Value<int> documentId,
    });

final class $$NotationTableReferences
    extends BaseReferences<_$AppDatabase, $NotationTable, NotationData> {
  $$NotationTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentTable _documentIdTable(_$AppDatabase db) =>
      db.document.createAlias(
        $_aliasNameGenerator(db.notation.documentId, db.document.id),
      );

  $$DocumentTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DocumentTableTableManager(
      $_db,
      $_db.document,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotationTableFilterComposer
    extends Composer<_$AppDatabase, $NotationTable> {
  $$NotationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentTableFilterComposer get documentId {
    final $$DocumentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableFilterComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotationTableOrderingComposer
    extends Composer<_$AppDatabase, $NotationTable> {
  $$NotationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentTableOrderingComposer get documentId {
    final $$DocumentTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableOrderingComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotationTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotationTable> {
  $$NotationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<int> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  $$DocumentTableAnnotationComposer get documentId {
    final $$DocumentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.document,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentTableAnnotationComposer(
            $db: $db,
            $table: $db.document,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotationTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotationTable,
          NotationData,
          $$NotationTableFilterComposer,
          $$NotationTableOrderingComposer,
          $$NotationTableAnnotationComposer,
          $$NotationTableCreateCompanionBuilder,
          $$NotationTableUpdateCompanionBuilder,
          (NotationData, $$NotationTableReferences),
          NotationData,
          PrefetchHooks Function({bool documentId})
        > {
  $$NotationTableTableManager(_$AppDatabase db, $NotationTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotationTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotationTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> posX = const Value.absent(),
                Value<int> posY = const Value.absent(),
                Value<int> documentId = const Value.absent(),
              }) => NotationCompanion(
                id: id,
                content: content,
                page: page,
                posX: posX,
                posY: posY,
                documentId: documentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                required int page,
                required int posX,
                required int posY,
                required int documentId,
              }) => NotationCompanion.insert(
                id: id,
                content: content,
                page: page,
                posX: posX,
                posY: posY,
                documentId: documentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotationTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$NotationTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$NotationTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotationTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotationTable,
      NotationData,
      $$NotationTableFilterComposer,
      $$NotationTableOrderingComposer,
      $$NotationTableAnnotationComposer,
      $$NotationTableCreateCompanionBuilder,
      $$NotationTableUpdateCompanionBuilder,
      (NotationData, $$NotationTableReferences),
      NotationData,
      PrefetchHooks Function({bool documentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoryTableTableManager get category =>
      $$CategoryTableTableManager(_db, _db.category);
  $$ConfigTableTableManager get config =>
      $$ConfigTableTableManager(_db, _db.config);
  $$DocumentTableTableManager get document =>
      $$DocumentTableTableManager(_db, _db.document);
  $$MarkupTableTableManager get markup =>
      $$MarkupTableTableManager(_db, _db.markup);
  $$NotationTableTableManager get notation =>
      $$NotationTableTableManager(_db, _db.notation);
}
