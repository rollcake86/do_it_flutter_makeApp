import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'music.dart';

class MusicDatabase{
  final Database database;

  MusicDatabase(this.database);

  static Future<Database> initDatabase() async {
    // 데이터베이스를 초기화합니다.
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'music_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE music('
              'id INTEGER PRIMARY KEY,'
              'name TEXT,'
              'composer TEXT,'
              'tag TEXT,'
              'category TEXT,'
              'size INTEGER,'
              'type TEXT,'
              'downloadUrl TEXT,'
              'imageDownloadUrl TEXT'
              ')',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<void> insertMusic(Music music) async {
    final Database db = database;
    // 데이터베이스에 음악 정보를 추가합니다.
    await db.insert(
      'music',
      music.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // 중복되었을 때 교체
    ).then((value) => print("success save"));
  }

  // 데이터 베이스를 검색합니다.
  Future<List<Map<String, dynamic>>> getMusic() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(join(dbPath, 'music_database.db'));
    return db.query('music');
  }

  // 모든 데이터베이스를 삭제
  Future<void> deleteMusicDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'music_database.db');
    await deleteDatabase(path);
  }
}