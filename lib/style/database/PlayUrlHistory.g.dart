// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlayUrlHistory.dart';

// ignore_for_file: type=lint
class $PlayUrlHistoryTableTable extends PlayUrlHistoryTable
    with TableInfo<$PlayUrlHistoryTableTable, PlayUrlHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayUrlHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _playUrlMeta =
      const VerificationMeta('playUrl');
  @override
  late final GeneratedColumn<String> playUrl = GeneratedColumn<String>(
      'play_url', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1, maxTextLength: 2000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [title, playUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_url_history_table';
  @override
  VerificationContext validateIntegrity(Insertable<PlayUrlHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('play_url')) {
      context.handle(_playUrlMeta,
          playUrl.isAcceptableOrUnknown(data['play_url']!, _playUrlMeta));
    } else if (isInserting) {
      context.missing(_playUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {title};
  @override
  PlayUrlHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayUrlHistory(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      playUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}play_url'])!,
    );
  }

  @override
  $PlayUrlHistoryTableTable createAlias(String alias) {
    return $PlayUrlHistoryTableTable(attachedDatabase, alias);
  }
}

class PlayUrlHistory extends DataClass implements Insertable<PlayUrlHistory> {
  final String title;
  final String playUrl;
  const PlayUrlHistory({required this.title, required this.playUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['play_url'] = Variable<String>(playUrl);
    return map;
  }

  PlayUrlHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return PlayUrlHistoryTableCompanion(
      title: Value(title),
      playUrl: Value(playUrl),
    );
  }

  factory PlayUrlHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayUrlHistory(
      title: serializer.fromJson<String>(json['title']),
      playUrl: serializer.fromJson<String>(json['playUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'playUrl': serializer.toJson<String>(playUrl),
    };
  }

  PlayUrlHistory copyWith({String? title, String? playUrl}) => PlayUrlHistory(
        title: title ?? this.title,
        playUrl: playUrl ?? this.playUrl,
      );
  PlayUrlHistory copyWithCompanion(PlayUrlHistoryTableCompanion data) {
    return PlayUrlHistory(
      title: data.title.present ? data.title.value : this.title,
      playUrl: data.playUrl.present ? data.playUrl.value : this.playUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayUrlHistory(')
          ..write('title: $title, ')
          ..write('playUrl: $playUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, playUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayUrlHistory &&
          other.title == this.title &&
          other.playUrl == this.playUrl);
}

class PlayUrlHistoryTableCompanion extends UpdateCompanion<PlayUrlHistory> {
  final Value<String> title;
  final Value<String> playUrl;
  final Value<int> rowid;
  const PlayUrlHistoryTableCompanion({
    this.title = const Value.absent(),
    this.playUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayUrlHistoryTableCompanion.insert({
    required String title,
    required String playUrl,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        playUrl = Value(playUrl);
  static Insertable<PlayUrlHistory> custom({
    Expression<String>? title,
    Expression<String>? playUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (playUrl != null) 'play_url': playUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayUrlHistoryTableCompanion copyWith(
      {Value<String>? title, Value<String>? playUrl, Value<int>? rowid}) {
    return PlayUrlHistoryTableCompanion(
      title: title ?? this.title,
      playUrl: playUrl ?? this.playUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (playUrl.present) {
      map['play_url'] = Variable<String>(playUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayUrlHistoryTableCompanion(')
          ..write('title: $title, ')
          ..write('playUrl: $playUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayUrlHistoryTableTable playUrlHistoryTable =
      $PlayUrlHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [playUrlHistoryTable];
}

typedef $$PlayUrlHistoryTableTableCreateCompanionBuilder
    = PlayUrlHistoryTableCompanion Function({
  required String title,
  required String playUrl,
  Value<int> rowid,
});
typedef $$PlayUrlHistoryTableTableUpdateCompanionBuilder
    = PlayUrlHistoryTableCompanion Function({
  Value<String> title,
  Value<String> playUrl,
  Value<int> rowid,
});

class $$PlayUrlHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayUrlHistoryTableTable> {
  $$PlayUrlHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playUrl => $composableBuilder(
      column: $table.playUrl, builder: (column) => ColumnFilters(column));
}

class $$PlayUrlHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayUrlHistoryTableTable> {
  $$PlayUrlHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playUrl => $composableBuilder(
      column: $table.playUrl, builder: (column) => ColumnOrderings(column));
}

class $$PlayUrlHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayUrlHistoryTableTable> {
  $$PlayUrlHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get playUrl =>
      $composableBuilder(column: $table.playUrl, builder: (column) => column);
}

class $$PlayUrlHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayUrlHistoryTableTable,
    PlayUrlHistory,
    $$PlayUrlHistoryTableTableFilterComposer,
    $$PlayUrlHistoryTableTableOrderingComposer,
    $$PlayUrlHistoryTableTableAnnotationComposer,
    $$PlayUrlHistoryTableTableCreateCompanionBuilder,
    $$PlayUrlHistoryTableTableUpdateCompanionBuilder,
    (
      PlayUrlHistory,
      BaseReferences<_$AppDatabase, $PlayUrlHistoryTableTable, PlayUrlHistory>
    ),
    PlayUrlHistory,
    PrefetchHooks Function()> {
  $$PlayUrlHistoryTableTableTableManager(
      _$AppDatabase db, $PlayUrlHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayUrlHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayUrlHistoryTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayUrlHistoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> playUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayUrlHistoryTableCompanion(
            title: title,
            playUrl: playUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String playUrl,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayUrlHistoryTableCompanion.insert(
            title: title,
            playUrl: playUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayUrlHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayUrlHistoryTableTable,
    PlayUrlHistory,
    $$PlayUrlHistoryTableTableFilterComposer,
    $$PlayUrlHistoryTableTableOrderingComposer,
    $$PlayUrlHistoryTableTableAnnotationComposer,
    $$PlayUrlHistoryTableTableCreateCompanionBuilder,
    $$PlayUrlHistoryTableTableUpdateCompanionBuilder,
    (
      PlayUrlHistory,
      BaseReferences<_$AppDatabase, $PlayUrlHistoryTableTable, PlayUrlHistory>
    ),
    PlayUrlHistory,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayUrlHistoryTableTableTableManager get playUrlHistoryTable =>
      $$PlayUrlHistoryTableTableTableManager(_db, _db.playUrlHistoryTable);
}
