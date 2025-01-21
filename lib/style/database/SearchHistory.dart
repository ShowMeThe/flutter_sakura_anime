
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';


@DataClassName('SearchHistory')
class SearchHistoryTable extends Table{

  TextColumn get title => text().withLength(min: 1, max: 255)();

  IntColumn get time => integer()();

  @override
  Set<Column> get primaryKey => {title};
}

