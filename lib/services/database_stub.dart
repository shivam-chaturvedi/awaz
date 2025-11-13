// Stub for sqflite on web
class ConflictAlgorithm {
  static const ConflictAlgorithm replace = ConflictAlgorithm._();
  const ConflictAlgorithm._();
}

class Database {
  Future<void> execute(String sql) async {}
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async => [];
  Future<int> insert(String table, Map<String, dynamic> values, {ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs}) async => 0;
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async => 0;
}

Future<Database> openDatabase(String path, {int version = 1, Function? onCreate}) async {
  if (onCreate != null) {
    final db = Database();
    await onCreate(db, version);
  }
  return Database();
}
