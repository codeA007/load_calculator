import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/part.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'load_calculator.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE parts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            part_no TEXT NOT NULL UNIQUE COLLATE NOCASE,
            description TEXT,
            weight_kg REAL NOT NULL,
            vendor_name TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_parts_description ON parts(description)',
        );
      },
    );
  }

  Future<int> insertPart(Part part) async {
    final db = await database;
    return db.insert('parts', part.toMap());
  }

  Future<int> updatePart(Part part) async {
    final db = await database;
    return db.update(
      'parts',
      part.toMap(),
      where: 'id = ?',
      whereArgs: [part.id],
    );
  }

  Future<int> deletePart(int id) async {
    final db = await database;
    return db.delete(
      'parts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Part?> getPartById(int id) async {
    final db = await database;
    final rows = await db.query(
      'parts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Part.fromMap(rows.first);
  }

  Future<Part?> getPartByPartNo(String partNo) async {
    final db = await database;
    final rows = await db.query(
      'parts',
      where: 'part_no = ? COLLATE NOCASE',
      whereArgs: [partNo.trim()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Part.fromMap(rows.first);
  }

  Future<List<Part>> getAllParts({String? query}) async {
    final db = await database;
    if (query == null || query.trim().isEmpty) {
      final rows = await db.query(
        'parts',
        orderBy: 'part_no COLLATE NOCASE ASC',
      );
      return rows.map(Part.fromMap).toList();
    }

    final pattern = '%${query.trim()}%';
    final rows = await db.query(
      'parts',
      where: 'part_no LIKE ? OR description LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'part_no COLLATE NOCASE ASC',
    );
    return rows.map(Part.fromMap).toList();
  }

  Future<List<Part>> searchParts(String query, {int limit = 20}) async {
    final db = await database;
    if (query.trim().isEmpty) {
      return [];
    }

    final pattern = '%${query.trim()}%';
    final rows = await db.query(
      'parts',
      where: 'part_no LIKE ? OR description LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'part_no COLLATE NOCASE ASC',
      limit: limit,
    );
    return rows.map(Part.fromMap).toList();
  }

  Future<int> getPartsCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM parts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> upsertPart(Part part) async {
    final existing = await getPartByPartNo(part.partNo);
    if (existing == null) {
      await insertPart(part);
    } else {
      await updatePart(
        part.copyWith(
          id: existing.id,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}
