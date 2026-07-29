import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/load_group.dart';
import '../models/load_group_item.dart';
import '../models/part.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'load_calculator.db';
  static const _dbVersion = 2;

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
        await _createPartsTable(db);
        await _createLoadGroupsTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createLoadGroupsTables(db);
        }
      },
    );
  }

  Future<void> _createPartsTable(Database db) async {
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
  }

  Future<void> _createLoadGroupsTables(Database db) async {
    await db.execute('''
      CREATE TABLE load_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_weight_kg REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE load_group_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        part_id INTEGER,
        part_no TEXT NOT NULL,
        description TEXT,
        unit_weight_kg REAL NOT NULL,
        quantity REAL NOT NULL,
        line_weight_kg REAL NOT NULL,
        FOREIGN KEY (group_id) REFERENCES load_groups(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_load_group_items_group_id ON load_group_items(group_id)',
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

  Future<int> insertLoadGroup(LoadGroup group) async {
    final db = await database;
    return db.transaction((txn) async {
      final groupId = await txn.insert('load_groups', group.toMap());
      for (final item in group.items) {
        await txn.insert(
          'load_group_items',
          item.copyWith(groupId: groupId).toMap(),
        );
      }
      return groupId;
    });
  }

  Future<List<LoadGroup>> getAllLoadGroups() async {
    final db = await database;
    final rows = await db.query(
      'load_groups',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => LoadGroup.fromMap(row)).toList();
  }

  Future<LoadGroup?> getLoadGroupById(int id) async {
    final db = await database;
    final groupRows = await db.query(
      'load_groups',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (groupRows.isEmpty) {
      return null;
    }

    final itemRows = await db.query(
      'load_group_items',
      where: 'group_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    final items = itemRows.map(LoadGroupItem.fromMap).toList();
    return LoadGroup.fromMap(groupRows.first, items: items);
  }

  Future<int> getLoadGroupsCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM load_groups');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteLoadGroup(int id) async {
    final db = await database;
    await db.delete(
      'load_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addItemsToLoadGroup(int groupId, List<LoadGroupItem> items) async {
    if (items.isEmpty) {
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          'load_group_items',
          item.copyWith(groupId: groupId).toMap(),
        );
      }

      final sumResult = await txn.rawQuery(
        'SELECT SUM(line_weight_kg) as total FROM load_group_items WHERE group_id = ?',
        [groupId],
      );
      final total = (sumResult.first['total'] as num?)?.toDouble() ?? 0;

      await txn.update(
        'load_groups',
        {'total_weight_kg': total},
        where: 'id = ?',
        whereArgs: [groupId],
      );
    });
  }

  Future<void> deleteLoadGroupItem(int itemId, int groupId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'load_group_items',
        where: 'id = ?',
        whereArgs: [itemId],
      );

      final sumResult = await txn.rawQuery(
        'SELECT SUM(line_weight_kg) as total FROM load_group_items WHERE group_id = ?',
        [groupId],
      );
      final total = (sumResult.first['total'] as num?)?.toDouble() ?? 0;

      await txn.update(
        'load_groups',
        {'total_weight_kg': total},
        where: 'id = ?',
        whereArgs: [groupId],
      );
    });
  }
}
