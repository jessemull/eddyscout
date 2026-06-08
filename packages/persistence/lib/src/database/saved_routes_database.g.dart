// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_routes_database.dart';

// ignore_for_file: type=lint
class $SavedRoutesTable extends SavedRoutes
    with TableInfo<$SavedRoutesTable, SavedRouteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _waypointsJsonMeta = const VerificationMeta(
    'waypointsJson',
  );
  @override
  late final GeneratedColumn<String> waypointsJson = GeneratedColumn<String>(
    'waypoints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geometryJsonMeta = const VerificationMeta(
    'geometryJson',
  );
  @override
  late final GeneratedColumn<String> geometryJson = GeneratedColumn<String>(
    'geometry_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    notes,
    isFavorite,
    isPrivate,
    waypointsJson,
    metadataJson,
    geometryJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedRouteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('waypoints_json')) {
      context.handle(
        _waypointsJsonMeta,
        waypointsJson.isAcceptableOrUnknown(
          data['waypoints_json']!,
          _waypointsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waypointsJsonMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('geometry_json')) {
      context.handle(
        _geometryJsonMeta,
        geometryJson.isAcceptableOrUnknown(
          data['geometry_json']!,
          _geometryJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedRouteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedRouteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      )!,
      waypointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waypoints_json'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      geometryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedRoutesTable createAlias(String alias) {
    return $SavedRoutesTable(attachedDatabase, alias);
  }
}

class SavedRouteRow extends DataClass implements Insertable<SavedRouteRow> {
  /// Primary key — local generated id.
  final String id;

  /// User-visible route name.
  final String name;

  /// Optional longer description.
  final String? description;

  /// Free-form notes.
  final String notes;

  /// Whether the user marked this route as a favorite.
  final bool isFavorite;

  /// Private by default in v1 (no cloud sync).
  final bool isPrivate;

  /// JSON array of route waypoints (core model).
  final String waypointsJson;

  /// JSON object of route metadata (core model).
  final String metadataJson;

  /// Optional JSON geometry snapshot (core model).
  final String? geometryJson;

  /// Created timestamp (Unix ms).
  final int createdAt;

  /// Last updated timestamp (Unix ms).
  final int updatedAt;
  const SavedRouteRow({
    required this.id,
    required this.name,
    this.description,
    required this.notes,
    required this.isFavorite,
    required this.isPrivate,
    required this.waypointsJson,
    required this.metadataJson,
    this.geometryJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['notes'] = Variable<String>(notes);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_private'] = Variable<bool>(isPrivate);
    map['waypoints_json'] = Variable<String>(waypointsJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    if (!nullToAbsent || geometryJson != null) {
      map['geometry_json'] = Variable<String>(geometryJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SavedRoutesCompanion toCompanion(bool nullToAbsent) {
    return SavedRoutesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: Value(notes),
      isFavorite: Value(isFavorite),
      isPrivate: Value(isPrivate),
      waypointsJson: Value(waypointsJson),
      metadataJson: Value(metadataJson),
      geometryJson: geometryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(geometryJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedRouteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedRouteRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String>(json['notes']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      waypointsJson: serializer.fromJson<String>(json['waypointsJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      geometryJson: serializer.fromJson<String?>(json['geometryJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String>(notes),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'waypointsJson': serializer.toJson<String>(waypointsJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'geometryJson': serializer.toJson<String?>(geometryJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SavedRouteRow copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? notes,
    bool? isFavorite,
    bool? isPrivate,
    String? waypointsJson,
    String? metadataJson,
    Value<String?> geometryJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => SavedRouteRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    notes: notes ?? this.notes,
    isFavorite: isFavorite ?? this.isFavorite,
    isPrivate: isPrivate ?? this.isPrivate,
    waypointsJson: waypointsJson ?? this.waypointsJson,
    metadataJson: metadataJson ?? this.metadataJson,
    geometryJson: geometryJson.present ? geometryJson.value : this.geometryJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedRouteRow copyWithCompanion(SavedRoutesCompanion data) {
    return SavedRouteRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      waypointsJson: data.waypointsJson.present
          ? data.waypointsJson.value
          : this.waypointsJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      geometryJson: data.geometryJson.present
          ? data.geometryJson.value
          : this.geometryJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedRouteRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('waypointsJson: $waypointsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    notes,
    isFavorite,
    isPrivate,
    waypointsJson,
    metadataJson,
    geometryJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedRouteRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.isFavorite == this.isFavorite &&
          other.isPrivate == this.isPrivate &&
          other.waypointsJson == this.waypointsJson &&
          other.metadataJson == this.metadataJson &&
          other.geometryJson == this.geometryJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedRoutesCompanion extends UpdateCompanion<SavedRouteRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> notes;
  final Value<bool> isFavorite;
  final Value<bool> isPrivate;
  final Value<String> waypointsJson;
  final Value<String> metadataJson;
  final Value<String?> geometryJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SavedRoutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.waypointsJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.geometryJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedRoutesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPrivate = const Value.absent(),
    required String waypointsJson,
    required String metadataJson,
    this.geometryJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       waypointsJson = Value(waypointsJson),
       metadataJson = Value(metadataJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedRouteRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<bool>? isFavorite,
    Expression<bool>? isPrivate,
    Expression<String>? waypointsJson,
    Expression<String>? metadataJson,
    Expression<String>? geometryJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isPrivate != null) 'is_private': isPrivate,
      if (waypointsJson != null) 'waypoints_json': waypointsJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (geometryJson != null) 'geometry_json': geometryJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedRoutesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? notes,
    Value<bool>? isFavorite,
    Value<bool>? isPrivate,
    Value<String>? waypointsJson,
    Value<String>? metadataJson,
    Value<String?>? geometryJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedRoutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
      waypointsJson: waypointsJson ?? this.waypointsJson,
      metadataJson: metadataJson ?? this.metadataJson,
      geometryJson: geometryJson ?? this.geometryJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (waypointsJson.present) {
      map['waypoints_json'] = Variable<String>(waypointsJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (geometryJson.present) {
      map['geometry_json'] = Variable<String>(geometryJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedRoutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('waypointsJson: $waypointsJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SavedRoutesDatabase extends GeneratedDatabase {
  _$SavedRoutesDatabase(QueryExecutor e) : super(e);
  $SavedRoutesDatabaseManager get managers => $SavedRoutesDatabaseManager(this);
  late final $SavedRoutesTable savedRoutes = $SavedRoutesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedRoutes];
}

typedef $$SavedRoutesTableCreateCompanionBuilder =
    SavedRoutesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String> notes,
      Value<bool> isFavorite,
      Value<bool> isPrivate,
      required String waypointsJson,
      required String metadataJson,
      Value<String?> geometryJson,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SavedRoutesTableUpdateCompanionBuilder =
    SavedRoutesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> notes,
      Value<bool> isFavorite,
      Value<bool> isPrivate,
      Value<String> waypointsJson,
      Value<String> metadataJson,
      Value<String?> geometryJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SavedRoutesTableFilterComposer
    extends Composer<_$SavedRoutesDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waypointsJson => $composableBuilder(
    column: $table.waypointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedRoutesTableOrderingComposer
    extends Composer<_$SavedRoutesDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waypointsJson => $composableBuilder(
    column: $table.waypointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedRoutesTableAnnotationComposer
    extends Composer<_$SavedRoutesDatabase, $SavedRoutesTable> {
  $$SavedRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get waypointsJson => $composableBuilder(
    column: $table.waypointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedRoutesTableTableManager
    extends
        RootTableManager<
          _$SavedRoutesDatabase,
          $SavedRoutesTable,
          SavedRouteRow,
          $$SavedRoutesTableFilterComposer,
          $$SavedRoutesTableOrderingComposer,
          $$SavedRoutesTableAnnotationComposer,
          $$SavedRoutesTableCreateCompanionBuilder,
          $$SavedRoutesTableUpdateCompanionBuilder,
          (
            SavedRouteRow,
            BaseReferences<
              _$SavedRoutesDatabase,
              $SavedRoutesTable,
              SavedRouteRow
            >,
          ),
          SavedRouteRow,
          PrefetchHooks Function()
        > {
  $$SavedRoutesTableTableManager(
    _$SavedRoutesDatabase db,
    $SavedRoutesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<String> waypointsJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String?> geometryJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedRoutesCompanion(
                id: id,
                name: name,
                description: description,
                notes: notes,
                isFavorite: isFavorite,
                isPrivate: isPrivate,
                waypointsJson: waypointsJson,
                metadataJson: metadataJson,
                geometryJson: geometryJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                required String waypointsJson,
                required String metadataJson,
                Value<String?> geometryJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedRoutesCompanion.insert(
                id: id,
                name: name,
                description: description,
                notes: notes,
                isFavorite: isFavorite,
                isPrivate: isPrivate,
                waypointsJson: waypointsJson,
                metadataJson: metadataJson,
                geometryJson: geometryJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$SavedRoutesDatabase,
      $SavedRoutesTable,
      SavedRouteRow,
      $$SavedRoutesTableFilterComposer,
      $$SavedRoutesTableOrderingComposer,
      $$SavedRoutesTableAnnotationComposer,
      $$SavedRoutesTableCreateCompanionBuilder,
      $$SavedRoutesTableUpdateCompanionBuilder,
      (
        SavedRouteRow,
        BaseReferences<_$SavedRoutesDatabase, $SavedRoutesTable, SavedRouteRow>,
      ),
      SavedRouteRow,
      PrefetchHooks Function()
    >;

class $SavedRoutesDatabaseManager {
  final _$SavedRoutesDatabase _db;
  $SavedRoutesDatabaseManager(this._db);
  $$SavedRoutesTableTableManager get savedRoutes =>
      $$SavedRoutesTableTableManager(_db, _db.savedRoutes);
}
