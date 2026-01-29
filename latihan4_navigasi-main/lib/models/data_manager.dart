import 'data_models.dart';
import 'database_helper.dart';

class DataManager {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== MATA KULIAH ====================
  static Future<List<MataKuliah>> loadMataKuliah() async {
    print('[DataManager] Loading mata kuliah...');
    final startTime = DateTime.now();
    final data = await _dbHelper.getMatakuliah();
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    print('[DataManager] Loaded ${data.length} items in ${duration}ms');
    
    return data
        .map((e) => MataKuliah(
              id: e['id'],
              nama: e['nama'],
              kode: e['kode'],
              sks: e['sks'],
              dosen: e['dosen'],
            ))
        .toList();
  }

  // Insert single mata kuliah dan return ID yang baru
  static Future<int> insertMataKuliah(MataKuliah mk) async {
    print('[DataManager] Inserting: ${mk.nama}');
    final startTime = DateTime.now();
    try {
      final result = await _dbHelper.insertMatakuliah({
        'nama': mk.nama,
        'kode': mk.kode ?? '',
        'sks': mk.sks ?? 0,
        'dosen': mk.dosen ?? '',
        'tanggalDibuat': DateTime.now().toIso8601String(),
      });
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[DataManager] ✓ Inserted in ${duration}ms');
      return result;
    } catch (e) {
      print('[DataManager] ❌ Insert error: $e');
      rethrow;
    }
  }

  // Update mata kuliah yang sudah ada
  static Future<int> updateMataKuliah(MataKuliah mk) async {
    if (mk.id == null) {
      throw Exception('ID tidak boleh null untuk update');
    }
    return await _dbHelper.updateMatakuliah({
      'id': mk.id,
      'nama': mk.nama,
      'kode': mk.kode ?? '',
      'sks': mk.sks ?? 0,
      'dosen': mk.dosen ?? '',
    });
  }

  // Delete mata kuliah
  static Future<int> deleteMataKuliah(int id) async {
    return await _dbHelper.deleteMatakuliah(id);
  }

  // ==================== JADWAL ====================
  static Future<List<Jadwal>> loadJadwal() async {
    final data = await _dbHelper.getJadwal();
    return data
        .map((e) => Jadwal(
              id: e['id'],
              idMatakuliah: e['idMatakuliah'],
              hari: e['hari'] ?? '',
              jamMulai: e['jamMulai'] ?? '',
              jamSelesai: e['jamSelesai'] ?? '',
              ruangan: e['ruangan'],
            ))
        .toList();
  }

  static Future<List<Jadwal>> loadJadwalByMataKuliah(int idMataKuliah) async {
    final data = await _dbHelper.getJadwalByMatakuliah(idMataKuliah);
    return data
        .map((e) => Jadwal(
              id: e['id'],
              idMatakuliah: e['idMatakuliah'],
              hari: e['hari'] ?? '',
              jamMulai: e['jamMulai'] ?? '',
              jamSelesai: e['jamSelesai'] ?? '',
              ruangan: e['ruangan'],
            ))
        .toList();
  }

  // Insert jadwal baru
  static Future<int> insertJadwal(Jadwal jadwal) async {
    if (jadwal.idMatakuliah == null) {
      throw Exception('idMatakuliah tidak boleh null');
    }
    return await _dbHelper.insertJadwal({
      'idMatakuliah': jadwal.idMatakuliah,
      'hari': jadwal.hari,
      'jamMulai': jadwal.jamMulai,
      'jamSelesai': jadwal.jamSelesai,
      'ruangan': jadwal.ruangan ?? '',
    });
  }

  // Update jadwal yang sudah ada
  static Future<int> updateJadwal(Jadwal jadwal) async {
    if (jadwal.id == null) {
      throw Exception('ID tidak boleh null untuk update');
    }
    return await _dbHelper.updateJadwal({
      'id': jadwal.id,
      'idMatakuliah': jadwal.idMatakuliah,
      'hari': jadwal.hari,
      'jamMulai': jadwal.jamMulai,
      'jamSelesai': jadwal.jamSelesai,
      'ruangan': jadwal.ruangan ?? '',
    });
  }

  // Delete jadwal
  static Future<int> deleteJadwal(int id) async {
    return await _dbHelper.deleteJadwal(id);
  }

  // ==================== TUGAS ====================
  static Future<List<Tugas>> loadTugas() async {
    final data = await _dbHelper.getTugas();
    return data
        .map((e) => Tugas(
              id: e['id'],
              idMatakuliah: e['idMatakuliah'],
              judul: e['judul'] ?? '',
              deskripsi: e['deskripsi'],
              deadline: e['deadline'] != null ? DateTime.tryParse(e['deadline']) : null,
              selesai: e['selesai'] == 1 ? true : false,
            ))
        .toList();
  }

  static Future<List<Tugas>> loadTugasByMataKuliah(int idMataKuliah) async {
    final data = await _dbHelper.getTugasByMatakuliah(idMataKuliah);
    return data
        .map((e) => Tugas(
              id: e['id'],
              idMatakuliah: e['idMatakuliah'],
              judul: e['judul'] ?? '',
              deskripsi: e['deskripsi'],
              deadline: e['deadline'] != null ? DateTime.tryParse(e['deadline']) : null,
              selesai: e['selesai'] == 1 ? true : false,
            ))
        .toList();
  }

  // Insert tugas baru
  static Future<int> insertTugas(Tugas tugas) async {
    return await _dbHelper.insertTugas({
      'idMatakuliah': tugas.idMatakuliah,
      'judul': tugas.judul,
      'deskripsi': tugas.deskripsi ?? '',
      'deadline': tugas.deadline?.toIso8601String() ?? '',
      'selesai': tugas.selesai ? 1 : 0,
      'tanggalDibuat': DateTime.now().toIso8601String(),
    });
  }

  // Update tugas yang sudah ada
  static Future<int> updateTugas(Tugas tugas) async {
    if (tugas.id == null) {
      throw Exception('ID tidak boleh null untuk update');
    }
    return await _dbHelper.updateTugas({
      'id': tugas.id,
      'idMatakuliah': tugas.idMatakuliah,
      'judul': tugas.judul,
      'deskripsi': tugas.deskripsi ?? '',
      'deadline': tugas.deadline?.toIso8601String() ?? '',
      'selesai': tugas.selesai ? 1 : 0,
    });
  }

  // Update status tugas selesai/belum selesai
  static Future<int> updateTugasStatus(int id, bool selesai) async {
    return await _dbHelper.updateTugas({
      'id': id,
      'selesai': selesai ? 1 : 0,
    });
  }

  // Delete tugas
  static Future<int> deleteTugas(int id) async {
    return await _dbHelper.deleteTugas(id);
  }

  // ==================== PROFIL ====================
  static Future<Profil> loadProfil() async {
    final data = await _dbHelper.getProfil();
    if (data != null) {
      return Profil(
        id: data['id'],
        nama: data['nama'] ?? '',
        npm: data['npm'] ?? '',
        email: data['email'],
        noHp: data['noHp'],
        prodi: data['prodi'],
        semester: data['semester'],
      );
    }
    return Profil(
      nama: '',
      npm: '',
    );
  }

  static Future<void> saveProfil(Profil profil) async {
    final data = await _dbHelper.getProfil();
    if (data == null) {
      await _dbHelper.insertProfil({
        'nama': profil.nama,
        'npm': profil.npm,
        'email': profil.email ?? '',
        'noHp': profil.noHp ?? '',
        'prodi': profil.prodi ?? '',
        'semester': profil.semester ?? 1,
      });
    } else {
      await _dbHelper.updateProfil({
        'id': data['id'],
        'nama': profil.nama,
        'npm': profil.npm,
        'email': profil.email ?? '',
        'noHp': profil.noHp ?? '',
        'prodi': profil.prodi ?? '',
        'semester': profil.semester ?? 1,
      });
    }
  }
}
