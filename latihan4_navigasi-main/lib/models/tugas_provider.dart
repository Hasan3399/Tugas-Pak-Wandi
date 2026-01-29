import 'package:flutter/material.dart';
import 'data_models.dart';
import 'data_manager.dart';

/// Provider untuk manajemen state Tugas
/// Memastikan sinkronisasi data tugas di seluruh aplikasi
class TugasProvider extends ChangeNotifier {
  List<Tugas> _tugas = [];
  bool _isLoading = false;
  String? _error;

  // Getter
  List<Tugas> get tugas => _tugas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stats
  int get totalTugas => _tugas.length;
  int get selesai => _tugas.where((t) => t.selesai).length;
  int get belumSelesai => totalTugas - selesai;
  double get progress => totalTugas == 0 ? 0 : (selesai / totalTugas) * 100;

  /// Load semua tugas dari database
  Future<void> loadTugas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tugasData = await DataManager.loadTugas();
      final mkData = await DataManager.loadMataKuliah();

      // Load nama untuk setiap tugas
      for (var t in tugasData) {
        if (t.idMatakuliah != null) {
          final mkWithName = mkData.firstWhere(
            (mk) => mk.id == t.idMatakuliah,
            orElse: () => MataKuliah(nama: 'Unknown', id: t.idMatakuliah),
          );
          t.mataKuliah = mkWithName.nama;
        }
      }

      _tugas = tugasData;
    } catch (e) {
      _error = e.toString();
      print('[TugasProvider] Error loading tugas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah tugas baru
  Future<void> addTugas(Tugas tugas) async {
    try {
      final id = await DataManager.insertTugas(tugas);
      tugas.id = id;
      _tugas.add(tugas);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update status tugas (selesai/belum)
  Future<void> updateTugasStatus(int tugasId, bool selesai) async {
    try {
      await DataManager.updateTugasStatus(tugasId, selesai);

      // Update di list lokal
      final index = _tugas.indexWhere((t) => t.id == tugasId);
      if (index != -1) {
        _tugas[index].selesai = selesai;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update detail tugas
  Future<void> updateTugas(Tugas tugas) async {
    try {
      await DataManager.updateTugas(tugas);

      // Update di list lokal
      final index = _tugas.indexWhere((t) => t.id == tugas.id);
      if (index != -1) {
        _tugas[index] = tugas;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Hapus tugas
  Future<void> deleteTugas(int tugasId) async {
    try {
      await DataManager.deleteTugas(tugasId);
      _tugas.removeWhere((t) => t.id == tugasId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh data dari database
  Future<void> refresh() async {
    await loadTugas();
  }

  /// Get tugas yang belum selesai
  List<Tugas> getTugasBelumSelesai() {
    return _tugas.where((t) => !t.selesai).toList();
  }

  /// Get tugas yang sudah selesai
  List<Tugas> getTugasSelesai() {
    return _tugas.where((t) => t.selesai).toList();
  }

  /// Get tugas berdasarkan mata kuliah
  List<Tugas> getTugasByMataKuliah(int idMataKuliah) {
    return _tugas.where((t) => t.idMatakuliah == idMataKuliah).toList();
  }
}
