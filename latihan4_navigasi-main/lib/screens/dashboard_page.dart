import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'input_mk_page.dart';
import 'atur_jadwal_page.dart';
import 'pengingat_tugas_page.dart';
import 'laporan_tugas_page.dart';
import 'profil_page.dart';

import '../models/data_models.dart';
import '../models/data_manager.dart';
import '../models/tugas_state_notifier.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TugasStateNotifier _tugasNotifier;

  int _petLevel = 1;
  int _selectedNavIndex = 0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _tugasNotifier = TugasStateNotifier();
    _tugasNotifier.addListener(_onTugasChanged);
    _loadTugas();
    _updatePetLevel();
    
    // Initialize rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _tugasNotifier.removeListener(_onTugasChanged);
    super.dispose();
  }

  void _onTugasChanged() {
    setState(() {
      // Rebuild ketika ada perubahan di TugasStateNotifier
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTugas();
  }

  @override
  void didUpdateWidget(DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadTugas();
  }

  // ===================== DATA TUGAS =====================
  Future<void> _loadTugas() async {
    await _tugasNotifier.loadTugas();
    setState(() {});
  }

  int get _totalTugas => _tugasNotifier.totalTugas;
  int get _selesai => _tugasNotifier.selesai;
  int get _belumSelesai => _tugasNotifier.belumSelesai;
  double get _progress => _tugasNotifier.progress;

  // ===================== PET LOGIC =====================
  Future<void> _updatePetLevel() async {
    final prefs = await SharedPreferences.getInstance();

    int level = prefs.getInt('petLevel') ?? 1;
    String? lastOpen = prefs.getString('lastOpen');

    DateTime now = DateTime.now();
    DateTime? lastDate =
        lastOpen != null ? DateTime.parse(lastOpen) : null;

    // Naik level jika buka di hari berbeda
    if (lastDate == null || now.difference(lastDate).inHours >= 12) {
      if (level < 4) level++;
    }

    await prefs.setInt('petLevel', level);
    await prefs.setString('lastOpen', now.toIso8601String());

    setState(() {
      _petLevel = level;
    });
  }

  double _petSize() {
    switch (_petLevel) {
      case 1:
        return 60;
      case 2:
        return 80;
      case 3:
        return 100;
      case 4:
        return 120;
      default:
        return 60;
    }
  }

  String _petText() {
    switch (_petLevel) {
      case 1:
        return 'Nagamu masih telur 🥚';
      case 2:
        return 'Nagamu mulai menetas 🐉';
      case 3:
        return 'Nagamu makin berkembang 🐲';
      case 4:
        return 'Nagamu sangat powerful! 🔥';
      default:
        return '';
    }
  }

  String _getPetEmoji() {
    switch (_petLevel) {
      case 1:
        return '🥚';
      case 2:
        return '🐉';
      case 3:
        return '🐲';
      case 4:
        return '🐉';
      default:
        return '🥚';
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===================== HORIZONTAL NAVIGATION =====================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _navButton('Input MK', Icons.book, 0, () {
                  _nav(const InputMKPage());
                }),
                _navButton('Atur Jadwal', Icons.schedule, 1, () {
                  _nav(const AturJadwalPage());
                }),
                _navButton('Pengingat Tugas', Icons.notifications, 2, () {
                  _nav(const PengingatTugasPage());
                }),
                _navButton('Laporan Tugas', Icons.report, 3, () {
                  _nav(const LaporanTugasPage());
                }),
                _navButton('Profil Mahasiswa', Icons.person, 4, () {
                  _nav(const ProfilPage());
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // ===================== BODY CONTENT =====================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // ===================== PET =====================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6B46C1).withOpacity(0.15),
                            const Color(0xFFDC2626).withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Level Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6B46C1),
                                  Color(0xFFDC2626),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Naga Level $_petLevel / 4',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Pet Icon 3D Effect
                          GestureDetector(
                            onTap: () {
                              // Can add interaction here
                            },
                            child: AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // perspective
                                    ..rotateY(_rotationController.value * 2 * pi)
                                    ..rotateX(sin(_rotationController.value * 2 * pi) * 0.3),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFDC2626)
                                              .withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getPetEmoji(),
                                      style: TextStyle(
                                        fontSize: _petSize(),
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Pet Status Text
                          Text(
                            _petText(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Level Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _petLevel / 4,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation(
                                Color(
                                  _petLevel == 4
                                      ? 0xFFDC2626
                                      : (_petLevel == 3
                                          ? 0xFFF97316
                                          : (_petLevel == 2
                                              ? 0xFF9333EA
                                              : 0xFF6B46C1)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Buka aplikasi setiap 12 jam untuk menumbuhkan nagamu! 🔥',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===================== JUDUL =====================
                  const Text(
                    'Selamat Datang di Dashboard Ingetin',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Kelola jadwal dan tugasmu dengan mudah',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // ===================== RINGKASAN TUGAS =====================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Tugas',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text('📌 Total tugas: $_totalTugas'),
                          const SizedBox(height: 6),
                          Text('✅ Selesai: $_selesai',
                              style: const TextStyle(color: Colors.green)),
                          const SizedBox(height: 6),
                          Text('⏳ Belum selesai: $_belumSelesai',
                              style: const TextStyle(color: Colors.orange)),
                          const SizedBox(height: 12),
                          Text(
                            '📊 Progress: ${_progress.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7494EC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTugas,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // ===================== HELPER =====================
  void _nav(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _navButton(String title, IconData icon, int index,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7494EC),
          side: const BorderSide(color: Color(0xFF7494EC), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}
