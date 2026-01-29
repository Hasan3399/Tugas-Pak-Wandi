import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static SharedPreferences? _prefs;
  static bool _isWeb = false;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_isWeb) {
      throw Exception('Web platform - should use SharedPreferences instead');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('[DB] Initializing database...');
    
    try {
      String path = join(await getDatabasesPath(), 'app.db');
      print('[DB] Database path: $path');
      
      return openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('[DB] ⚠ Error initializing sqflite: $e');
      print('[DB] Will retry with error handling...');
      
      // Check if it's a web platform error
      if (e.toString().contains('databaseFactory') || 
          e.toString().contains('getDatabasesPath')) {
        _isWeb = true;
        print('[DB] Switching to SharedPreferences for web');
        _prefs = await SharedPreferences.getInstance();
      }
      
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Mata Kuliah
    await db.execute('''
      CREATE TABLE matakuliah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kode TEXT,
        sks INTEGER,
        dosen TEXT,
        tanggalDibuat TEXT
      )
    ''');

    // Tabel Jadwal
    await db.execute('''
      CREATE TABLE jadwal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idMatakuliah INTEGER NOT NULL,
        hari TEXT,
        jamMulai TEXT,
        jamSelesai TEXT,
        ruangan TEXT,
        FOREIGN KEY (idMatakuliah) REFERENCES matakuliah(id)
      )
    ''');

    // Tabel Tugas
    await db.execute('''
      CREATE TABLE tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idMatakuliah INTEGER,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        deadline TEXT,
        selesai INTEGER DEFAULT 0,
        tanggalDibuat TEXT,
        FOREIGN KEY (idMatakuliah) REFERENCES matakuliah(id)
      )
    ''');

    // Tabel User Profile
    await db.execute('''
      CREATE TABLE profil (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        npm TEXT,
        email TEXT,
        noHp TEXT,
        prodi TEXT,
        semester INTEGER
      )
    ''');
  }

  // ==================== MATA KULIAH ====================
  Future<int> insertMatakuliah(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('matakuliah');
      int newId = (items.isEmpty ? 0 : items.last['id'] as int) + 1;
      data['id'] = newId;
      items.add(data);
      await _prefs!.setString('matakuliah', jsonEncode(items));
      return newId;
    }
    Database db = await database;
    return await db.insert('matakuliah', data);
  }

  Future<List<Map<String, dynamic>>> getMatakuliah() async {
    if (_isWeb) {
      return await _getWebData('matakuliah');
    }
    Database db = await database;
    return await db.query('matakuliah');
  }

  Future<int> updateMatakuliah(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('matakuliah');
      final idx = items.indexWhere((e) => e['id'] == data['id']);
      if (idx >= 0) {
        items[idx] = data;
        await _prefs!.setString('matakuliah', jsonEncode(items));
      }
      return 1;
    }
    Database db = await database;
    return await db.update('matakuliah', data,
        where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> deleteMatakuliah(int id) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('matakuliah');
      items.removeWhere((e) => e['id'] == id);
      await _prefs!.setString('matakuliah', jsonEncode(items));
      return 1;
    }
    Database db = await database;
    return await db.delete('matakuliah', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== JADWAL ====================
  Future<int> insertJadwal(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('jadwal');
      int newId = (items.isEmpty ? 0 : items.last['id'] as int) + 1;
      data['id'] = newId;
      items.add(data);
      await _prefs!.setString('jadwal', jsonEncode(items));
      return newId;
    }
    Database db = await database;
    return await db.insert('jadwal', data);
  }

  Future<List<Map<String, dynamic>>> getJadwal() async {
    if (_isWeb) {
      return await _getWebData('jadwal');
    }
    Database db = await database;
    return await db.query('jadwal');
  }

  Future<List<Map<String, dynamic>>> getJadwalByMatakuliah(
      int idMatakuliah) async {
    if (_isWeb) {
      final items = await _getWebData('jadwal');
      return items.where((e) => e['idMatakuliah'] == idMatakuliah).toList();
    }
    Database db = await database;
    return await db.query('jadwal',
        where: 'idMatakuliah = ?', whereArgs: [idMatakuliah]);
  }

  Future<int> updateJadwal(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('jadwal');
      final idx = items.indexWhere((e) => e['id'] == data['id']);
      if (idx >= 0) {
        items[idx] = data;
        await _prefs!.setString('jadwal', jsonEncode(items));
      }
      return 1;
    }
    Database db = await database;
    return await db.update('jadwal', data,
        where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> deleteJadwal(int id) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('jadwal');
      items.removeWhere((e) => e['id'] == id);
      await _prefs!.setString('jadwal', jsonEncode(items));
      return 1;
    }
    Database db = await database;
    return await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TUGAS ====================
  Future<int> insertTugas(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('tugas');
      int newId = (items.isEmpty ? 0 : items.last['id'] as int) + 1;
      data['id'] = newId;
      items.add(data);
      await _prefs!.setString('tugas', jsonEncode(items));
      return newId;
    }
    Database db = await database;
    return await db.insert('tugas', data);
  }

  Future<List<Map<String, dynamic>>> getTugas() async {
    if (_isWeb) {
      return await _getWebData('tugas');
    }
    Database db = await database;
    return await db.query('tugas');
  }

  Future<List<Map<String, dynamic>>> getTugasByMatakuliah(
      int idMatakuliah) async {
    if (_isWeb) {
      final items = await _getWebData('tugas');
      return items.where((e) => e['idMatakuliah'] == idMatakuliah).toList();
    }
    Database db = await database;
    return await db.query('tugas',
        where: 'idMatakuliah = ?', whereArgs: [idMatakuliah]);
  }

  Future<int> updateTugas(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('tugas');
      final idx = items.indexWhere((e) => e['id'] == data['id']);
      if (idx >= 0) {
        items[idx] = data;
        await _prefs!.setString('tugas', jsonEncode(items));
      }
      return 1;
    }
    Database db = await database;
    return await db.update('tugas', data,
        where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> deleteTugas(int id) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> items = await _getWebData('tugas');
      items.removeWhere((e) => e['id'] == id);
      await _prefs!.setString('tugas', jsonEncode(items));
      return 1;
    }
    Database db = await database;
    return await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PROFIL ====================
  Future<int> insertProfil(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      data['id'] = 1;
      await _prefs!.setString('profil', jsonEncode(data));
      return 1;
    }
    Database db = await database;
    return await db.insert('profil', data);
  }

  Future<Map<String, dynamic>?> getProfil() async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final str = _prefs!.getString('profil');
      if (str == null) return null;
      return jsonDecode(str) as Map<String, dynamic>;
    }
    Database db = await database;
    final result = await db.query('profil', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProfil(Map<String, dynamic> data) async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      data['id'] = 1;
      await _prefs!.setString('profil', jsonEncode(data));
      return 1;
    }
    Database db = await database;
    final existing = await db.query('profil', limit: 1);
    if (existing.isEmpty) {
      return await db.insert('profil', data);
    } else {
      return await db.update('profil', data, where: 'id = ?', whereArgs: [1]);
    }
  }

  // ==================== WEB HELPERS ====================
  Future<List<Map<String, dynamic>>> _getWebData(String table) async {
    _prefs ??= await SharedPreferences.getInstance();
    final str = _prefs!.getString(table);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      print('[DB] Error parsing $table: $e');
      return [];
    }
  }
}
