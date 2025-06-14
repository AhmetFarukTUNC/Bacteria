import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('user_db.db');
    return _database!;
  }
  Future<int> updateChatName({required int chatId, required String newName, required int userId}) async {
  final db = await database;
  return await db.update(
    'chat',
    {'baslik': newName},
    where: 'id = ? AND userId = ?',
    whereArgs: [chatId, userId],
  );
}


  // Veritabanı başlatma ve tablo oluşturma işlemleri
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    int? selectedChatId;


    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createPatientsTable(db);
    // Chatbot ve Chat tablosu artık yok
    await db.execute('''
      CREATE TABLE chat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        soru TEXT,
        cevap TEXT,
        baslik TEXT,
        userid INTEGER
      )
    ''');

  }
  Future<List<Map<String, dynamic>>> getChatsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'chat',
      where: 'userid = ?',
      whereArgs: [userId],
      groupBy: 'baslik', // aynı başlıklar bir kez gelsin
    );
  }

  // Yeni sohbet ekle
  Future<int> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    return await db.insert('chat', {
      'soru': '',
      'cevap': '',
      'baslik': chat['name'],
      'userid': chat['userId'],
    });
  }

  Future<List<Map<String, dynamic>>> getAllChats(int userId) async {
    final db = await database;
    return await db.query(
      'chat', // <-- tablo adınızı buraya yazın
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id ASC', // (opsiyonel) en yenisi en üstte gelsin
    );
  }


  Future<void> updateChatWithFirstMessage({
    required int chatId,
    required String soru,
    required String cevap,
  }) async {
    final db = await database;
    await db.update(
      'chat',
      {
        'soru': soru,
        'cevap': cevap,
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> deleteAllChatsForUser(int userId) async {
    final db = await database;
    await db.delete(
      'chat',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }


  Future<List<Map<String, dynamic>>> getChatsByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'chat',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }


  Future<Map<String, String>?> getChatQuestionAndAnswer(int chatId) async {
    final db = await database;
    final result = await db.query(
      'chat',
      columns: ['soru', 'cevap'],
      where: 'id = ?',
      whereArgs: [chatId],
    );

    if (result.isNotEmpty) {
      return {
        'soru': result.first['soru'] as String,
        'cevap': result.first['cevap'] as String,
      };
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMessagesByChatTitle(String chatTitle) async {
    final db = await database;

    // 'baslik' kolonuna göre chatId'yi bul
    final chatResult = await db.query(
      'chat',
      where: 'baslik = ?',
      whereArgs: [chatTitle],
    );

    if (chatResult.isEmpty) return [];

    final chatId = chatResult.first['id'];

    // O chatId'ye ait tüm mesajları getir
    return await db.query(
      'chatbot',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'id ASC',
    );
  }


  // Belirli sohbete ait soruları ve cevapları getir
  Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    final db = await database;
    return await db.query('chat', where: 'id = ?', whereArgs: [chatId]);
  }

  // Tüm sohbetleri sil
  Future<void> deleteAllChats(int userId) async {
    final db = await database;
    await db.delete('chat', where: 'userid = ?', whereArgs: [userId]);
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
      accuracy TEXT NOT NULL,
      bacteria_type TEXT NOT NULL,
      
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

  Future<void> checkAndCreatePatientsTable() async {
    final db = await instance.database;
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='patients'");

    if (tables.isEmpty) {
      await _createPatientsTable(db);
    }
  }

  // userId ve şifre ile kullanıcıyı alır
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

  Future<int?> getUserIdByEmailPassword(String email, String password) async {
    final db = await _database;
    var result = await db?.query(
      'users',
      columns: ['id'],
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result != null && result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }

  // Yeni kullanıcı ekler
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
