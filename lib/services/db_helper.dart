import 'package:bloom_a1/models/plant_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user_table.dart';
import '../models/watering_schedule_table.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'bloom_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emailOrPhone TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        description TEXT,
        light TEXT,
        temperature TEXT,
        summer TEXT,
        winter TEXT,
        soil TEXT,
        fertilization TEXT,
        benefits TEXT,
        warning TEXT,
        imageUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE watering_schedule (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plantId INTEGER NOT NULL,
      frequency TEXT NOT NULL,
      day TEXT NOT NULL
    )
''');
  }

  // User CRUD
  Future<int> insertUser(UserTable user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserTable?> getUserByEmailOrPhone(String emailOrPhone) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'emailOrPhone = ?',
      whereArgs: [emailOrPhone],
    );

    if (result.isNotEmpty) {
      return UserTable.fromMap(result.first);
    }
    return null;
  }

  // Plant CRUD
  Future<int> insertPlant(PlantTable plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap());
  }

  Future<List<PlantTable>> getPlants() async {
    final db = await database;
    final maps = await db.query('plants');
    return maps.map((map) => PlantTable.fromMap(map)).toList();
  }

  Future<List<PlantTable>> getPlantsByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'plants',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => PlantTable.fromMap(map)).toList();
  }

  Future<int> deletePlant(int id) async {
    final db = await database;
    return await db.delete('plants', where: 'id = ?', whereArgs: [id]);
  }

  //wateringSchedule CURD
  Future<int> insertWateringSchedule(
      WateringScheduleTable wateringSchedule) async {
    final db = await database;
    return await db.insert('watering_schedule', wateringSchedule.toMap());
  }

  Future<List<WateringScheduleTable>> getWateringScheduleByPlant(
      int plantId) async {
    final db = await database;
    final maps = await db.query(
      'watering_schedule',
      where: 'plantId = ?',
      whereArgs: [plantId],
    );
    return maps.map((map) => WateringScheduleTable.fromMap(map)).toList();
  }

  Future<int> deleteWateringSchedule(int id) async {
    final db = await database;
    return await db
        .delete('watering_schedule', where: 'id = ?', whereArgs: [id]);
  }
  //delete plant's Watering Schedule
  Future<int> deleteSchedule(int plantId) async {
    final db = await database;
    return await db
        .delete('watering_schedule', where: 'plantId = ?', whereArgs: [plantId]);
  }

  //update WateringSchedule
  Future<int> updateWateringSchedule(WateringScheduleTable schedule) async {
    final db = await database;
    return await db.update(
      'watering_schedule',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }
}
