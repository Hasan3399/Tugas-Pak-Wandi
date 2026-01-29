import 'data_models.dart';
import 'data_manager.dart';

/// Singleton global notifier untuk sinkronisasi state tugas
/// Menggunakan ValueNotifier untuk menghindari dependency tambahan
class TugasStateNotifier {
  static final TugasStateNotifier _instance = TugasStateNotifier._internal();

  factory TugasStateNotifier() {
    return _instance;
  }

  TugasStateNotifier._internal();

  // List untuk notify listeners ketika ada perubahan
  final List<Function()> _listeners = [];

  // Cache tugas
  List<Tugas> _tugasCache = [];

  List<Tugas> get tugas => _tugasCache;

  // Stats
  int get totalTugas => _tugasCache.length;
  int get selesai => _tugasCache.where((t) => t.selesai).length;
  int get belumSelesai => totalTugas - selesai;
  double get progress =>
      totalTugas == 0 ? 0 : (selesai / totalTugas) * 100;

  /// Register listener untuk perubahan
  void addListener(Function() callback) {
    _listeners.add(callback);
  }

  /// Remove listener
  void removeListener(Function() callback) {
    _listeners.remove(callback);
  }

  /// Notify semua listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  /// Load semua tugas dari database
  Future<void> loadTugas() async {
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

      _tugasCache = tugasData;
      _notifyListeners();
    } catch (e) {
      print('[TugasStateNotifier] Error loading tugas: $e');
    }
  }

  /// Tambah tugas baru
  Future<void> addTugas(Tugas tugas) async {
    try {
      final id = await DataManager.insertTugas(tugas);
      tugas.id = id;
      _tugasCache.add(tugas);
      _notifyListeners();
    } catch (e) {
      print('[TugasStateNotifier] Error adding tugas: $e');
      rethrow;
    }
  }

  /// Update status tugas (selesai/belum)
  /// Ini adalah method penting untuk sinkronisasi
  Future<void> updateTugasStatus(int tugasId, bool selesai) async {
    try {
      await DataManager.updateTugasStatus(tugasId, selesai);

      // Update di cache lokal
      final index = _tugasCache.indexWhere((t) => t.id == tugasId);
      if (index != -1) {
        _tugasCache[index].selesai = selesai;
      }

      // Notify semua listeners (termasuk home page, dashboard, laporan)
      _notifyListeners();
    } catch (e) {
      print('[TugasStateNotifier] Error updating status: $e');
      rethrow;
    }
  }

  /// Update detail tugas
  Future<void> updateTugas(Tugas tugas) async {
    try {
      await DataManager.updateTugas(tugas);

      // Update di cache lokal
      final index = _tugasCache.indexWhere((t) => t.id == tugas.id);
      if (index != -1) {
        _tugasCache[index] = tugas;
      }

      _notifyListeners();
    } catch (e) {
      print('[TugasStateNotifier] Error updating tugas: $e');
      rethrow;
    }
  }

  /// Hapus tugas
  Future<void> deleteTugas(int tugasId) async {
    try {
      await DataManager.deleteTugas(tugasId);
      _tugasCache.removeWhere((t) => t.id == tugasId);
      _notifyListeners();
    } catch (e) {
      print('[TugasStateNotifier] Error deleting tugas: $e');
      rethrow;
    }
  }

  /// Get tugas yang belum selesai
  List<Tugas> getTugasBelumSelesai() {
    return _tugasCache.where((t) => !t.selesai).toList();
  }

  /// Get tugas yang sudah selesai
  List<Tugas> getTugasSelesai() {
    return _tugasCache.where((t) => t.selesai).toList();
  }

  /// Clear cache
  void clear() {
    _tugasCache = [];
    _notifyListeners();
  }
}
