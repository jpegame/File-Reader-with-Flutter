import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/config.dart';

part 'config_dao.g.dart';

@DriftAccessor(tables: [Config])
class ConfigDao extends DatabaseAccessor<AppDatabase> with _$ConfigDaoMixin {
  ConfigDao(AppDatabase db) : super(db);

  Future<String?> getValue(String key) async {
    final query = select(config)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> upsertConfig(String key, String value) {
    return into(config).insert(
      ConfigCompanion.insert(key: key, value: value),
      onConflict: DoUpdate(
        (old) => ConfigCompanion.custom(value: Constant(value)),
        target: [config.key],
      ),
    );
  }
}
