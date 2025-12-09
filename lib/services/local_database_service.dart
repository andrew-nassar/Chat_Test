import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/message_model.dart'; // Make sure this import matches your project structure

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Creating the messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT,
        senderId TEXT,
        content TEXT,
        sentAt TEXT, 
        isRead INTEGER
      )
    ''');
  }

  // 1. Save a batch of messages (from API)
  Future<void> saveMessages(List<MessageDto> messages) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var msg in messages) {
      batch.insert(
        'messages',
        msg.toJson(), // Ensure your Model has .toJson()
        conflictAlgorithm: ConflictAlgorithm.replace, // Update if exists
      );
    }
    await batch.commit(noResult: true);
  }

  // 2. Get Messages (Pagination supported)
  Future<List<MessageDto>> getMessages(String conversationId, {int limit = 20, int offset = 0}) async {
    final db = await instance.database;
    
    final result = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'sentAt DESC', // Newest first
      limit: limit,
      offset: offset,
    );

    return result.map((json) => MessageDto.fromJson(json)).toList();
  }
}