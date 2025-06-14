import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatbotHelper {
  static final ChatbotHelper instance = ChatbotHelper._privateConstructor();
  static Database? _database;

  ChatbotHelper._privateConstructor();

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
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

  Future<int> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    return await db.insert('chat', {
      'soru': '',
      'cevap': '',
      'baslik': chat['name'],
      'userid': chat['userId'],
    });
  }


  Future<List<Map<String, dynamic>>> getChatsByUser(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT id, baslik FROM chat
      WHERE userid = ?
      GROUP BY baslik
      ORDER BY id DESC
    ''', [userId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    final db = await database;
    final result = await db.query(
      'chat',
      where: 'id = ? OR baslik = (SELECT baslik FROM chat WHERE id = ?)',
      whereArgs: [chatId, chatId],
      orderBy: 'id ASC',
    );
    return result;
  }

  Future<void> deleteAllChats(int userId) async {
    final db = await database;
    await db.delete('chat', where: 'userid = ?', whereArgs: [userId]);
  }
}
