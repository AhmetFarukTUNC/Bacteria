import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('user_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createPatientsTable(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        surname TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        specialization TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPatientsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS patients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,  -- Adding the user_id column
      name TEXT NOT NULL,
      dob TEXT NOT NULL,
      phone TEXT NOT NULL,
      disease TEXT NOT NULL,
      emergency_contact TEXT NOT NULL,
      emergency_phone TEXT NOT NULL,
      address TEXT NOT NULL,
      gender TEXT NOT NULL,
      image_path TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)  -- Adding the foreign key constraint
    )
  ''');
  }



  // userId ile eşleşen verileri alır
  Future<List<Map<String, dynamic>>> getPatientsByUserId(int userId) async {
    final db = await instance.database; // Veritabanına bağlanıyoruz
    try {
      var res = await db.query(
        'patients',  // 'patients' tablosu
        where: 'user_id = ?',  // user_id ile eşleşen satırları seçiyoruz
        whereArgs: [userId],  // userId parametresi ile eşleştirme yapıyoruz
      );
      return List<Map<String, dynamic>>.from(res);   // Eşleşen tüm verileri döndürüyoruz
    } catch (e) {
      print('Veritabanı hatası: $e');
      return [];  // Hata durumunda boş bir liste döndürüyoruz
    }
  }



  // ...

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
  final db = await instance.database;
  var res = await db.query(
  'users',
  where: 'email = ? AND password = ?',
  whereArgs: [email, password],
  );
  if (res.isNotEmpty) {
  return res.first;
  } else {
  return null;
  }
  }


  Future<void> checkAndCreatePatientsTable() async {
    final db = await instance.database;
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='patients'");

    if (tables.isEmpty) {
      await _createPatientsTable(db);
    }
  }

  // Function to get user by email and password
  Future<int?> getUserIdByEmailPassword(String email, String password) async {
    final db = await _database;
    var result = await db?.query(
      'users',
      columns: ['id'], // Assume 'id' is the primary key in your 'users' table
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result != null && result.isNotEmpty) {
      return result.first['id'] as int;  // Cast to int for consistency
    }
    return null; // Return null if no user is found
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<int> updateUser(Map<String, dynamic> user, int id) async {
    final db = await instance.database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Patients Table Methods
  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await instance.database;
    await checkAndCreatePatientsTable();
    return await db.insert('patients', patient);
  }

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    final db = await instance.database;
    await checkAndCreatePatientsTable();
    return await db.query('patients');
  }

  Future<Map<String, dynamic>?> getPatientById(int id) async {
    final db = await instance.database;
    await checkAndCreatePatientsTable();
    final result = await db.query('patients', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updatePatient(Map<String, dynamic> patient, int id) async {
    final db = await instance.database;
    await checkAndCreatePatientsTable();
    return await db.update('patients', patient, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    await checkAndCreatePatientsTable();
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
