import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalStorage {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'zerocontrol.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla de Activos (equivalente a Room)
        await db.execute('''
          CREATE TABLE activos(
            id TEXT PRIMARY KEY,
            name TEXT,
            location TEXT,
            address TEXT,
            status TEXT,
            statusColor INTEGER,
            temp TEXT,
            time TEXT,
            fechaVisita TEXT,
            tipoVisita TEXT,
            estadoEquipo TEXT,
            observacionesTecnico TEXT
          )
        ''');

        // Tabla de Entregas
        await db.execute('''
          CREATE TABLE entregas(
            id TEXT PRIMARY KEY,
            cliente TEXT,
            lugar TEXT,
            direccion TEXT,
            horario TEXT,
            equipo TEXT,
            status INTEGER,
            fechaConfirmacion TEXT
          )
        ''');
      },
    );
  }

  // Métodos CRUD para Activos
  static Future<void> insertActivo(Map<String, dynamic> activo) async {
    final db = await database;
    await db.insert('activos', activo, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getActivos() async {
    final db = await database;
    return await db.query('activos');
  }

  static Future<void> updateActivo(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('activos', data, where: 'id = ?', whereArgs: [id]);
  }

  // Métodos CRUD para Entregas
  static Future<void> insertEntrega(Map<String, dynamic> entrega) async {
    final db = await database;
    await db.insert('entregas', entrega, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getEntregas() async {
    final db = await database;
    return await db.query('entregas');
  }

  static Future<void> updateEntrega(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('entregas', data, where: 'id = ?', whereArgs: [id]);
  }
}
