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

class $SearchHistoryTableTable extends SearchHistoryTable
    with TableInfo<$SearchHistoryTableTable, SearchHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int> time = GeneratedColumn<int>(
      'time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [title, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_table';
  @override
  VerificationContext validateIntegrity(Insertable<SearchHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {title};
  @override
  SearchHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistory(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $SearchHistoryTableTable createAlias(String alias) {
    return $SearchHistoryTableTable(attachedDatabase, alias);
  }
}

class SearchHistory extends DataClass implements Insertable<SearchHistory> {
  final String title;
  final int time;
  const SearchHistory({required this.title, required this.time});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['time'] = Variable<int>(time);
    return map;
  }

  SearchHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryTableCompanion(
      title: Value(title),
      time: Value(time),
    );
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistory(
      title: serializer.fromJson<String>(json['title']),
      time: serializer.fromJson<int>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'time': serializer.toJson<int>(time),
    };
  }

  SearchHistory copyWith({String? title, int? time}) => SearchHistory(
        title: title ?? this.title,
        time: time ?? this.time,
      );
  SearchHistory copyWithCompanion(SearchHistoryTableCompanion data) {
    return SearchHistory(
      title: data.title.present ? data.title.value : this.title,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistory(')
          ..write('title: $title, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistory &&
          other.title == this.title &&
          other.time == this.time);
}

class SearchHistoryTableCompanion extends UpdateCompanion<SearchHistory> {
  final Value<String> title;
  final Value<int> time;
  final Value<int> rowid;
  const SearchHistoryTableCompanion({
    this.title = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryTableCompanion.insert({
    required String title,
    required int time,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        time = Value(time);
  static Insertable<SearchHistory> custom({
    Expression<String>? title,
    Expression<int>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryTableCompanion copyWith(
      {Value<String>? title, Value<int>? time, Value<int>? rowid}) {
    return SearchHistoryTableCompanion(
      title: title ?? this.title,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryTableCompanion(')
          ..write('title: $title, ')
          ..write('time: $time, ')
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
  late final $SearchHistoryTableTable searchHistoryTable =
      $SearchHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [playUrlHistoryTable, searchHistoryTable];
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
typedef $$SearchHistoryTableTableCreateCompanionBuilder
    = SearchHistoryTableCompanion Function({
  required String title,
  required int time,
  Value<int> rowid,
});
typedef $$SearchHistoryTableTableUpdateCompanionBuilder
    = SearchHistoryTableCompanion Function({
  Value<String> title,
  Value<int> time,
  Value<int> rowid,
});

class $$SearchHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));
}

class $$SearchHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));
}

class $$SearchHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$SearchHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchHistoryTableTable,
    SearchHistory,
    $$SearchHistoryTableTableFilterComposer,
    $$SearchHistoryTableTableOrderingComposer,
    $$SearchHistoryTableTableAnnotationComposer,
    $$SearchHistoryTableTableCreateCompanionBuilder,
    $$SearchHistoryTableTableUpdateCompanionBuilder,
    (
      SearchHistory,
      BaseReferences<_$AppDatabase, $SearchHistoryTableTable, SearchHistory>
    ),
    SearchHistory,
    PrefetchHooks Function()> {
  $$SearchHistoryTableTableTableManager(
      _$AppDatabase db, $SearchHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<int> time = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchHistoryTableCompanion(
            title: title,
            time: time,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required int time,
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchHistoryTableCompanion.insert(
            title: title,
            time: time,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchHistoryTableTable,
    SearchHistory,
    $$SearchHistoryTableTableFilterComposer,
    $$SearchHistoryTableTableOrderingComposer,
    $$SearchHistoryTableTableAnnotationComposer,
    $$SearchHistoryTableTableCreateCompanionBuilder,
    $$SearchHistoryTableTableUpdateCompanionBuilder,
    (
      SearchHistory,
      BaseReferences<_$AppDatabase, $SearchHistoryTableTable, SearchHistory>
    ),
    SearchHistory,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayUrlHistoryTableTableTableManager get playUrlHistoryTable =>
      $$PlayUrlHistoryTableTableTableManager(_db, _db.playUrlHistoryTable);
  $$SearchHistoryTableTableTableManager get searchHistoryTable =>
      $$SearchHistoryTableTableTableManager(_db, _db.searchHistoryTable);
}
