import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';

class LaporanTugasPage extends StatefulWidget {
  const LaporanTugasPage({super.key});

  @override
  _LaporanTugasPageState createState() => _LaporanTugasPageState();
}

class _LaporanTugasPageState extends State<LaporanTugasPage> {
  List<Tugas> _tugas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
    
    setState(() {
      _tugas = tugasData;
    });
  }

  void _toggleSelesai(int index) {
    final tugas = _tugas[index];
    tugas.selesai = !tugas.selesai;
    
    if (tugas.id != null) {
      DataManager.updateTugasStatus(tugas.id!, tugas.selesai).then((_) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tugas.selesai ? 'Tugas ditandai selesai' : 'Tugas ditandai belum selesai',
            ),
          ),
        );
      }).catchError((e) {
        setState(() {
          tugas.selesai = !tugas.selesai; // Revert
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
  }

  int get _totalTugas => _tugas.length;
  int get _selesai => _tugas.where((t) => t.selesai).length;
  int get _belumSelesai => _totalTugas - _selesai;
  double get _progress =>
      _totalTugas == 0 ? 0 : (_selesai / _totalTugas) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Tugas'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                color: const Color(0xFF7494EC),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Tugas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Total',
                            _totalTugas.toString(),
                            Colors.white,
                          ),
                          _buildSummaryItem(
                            'Selesai',
                            _selesai.toString(),
                            Colors.greenAccent,
                          ),
                          _buildSummaryItem(
                            'Belum',
                            _belumSelesai.toString(),
                            Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progress >= 100 ? Colors.greenAccent : Colors.orangeAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Progress: ${_progress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar Tugas:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _tugas.isEmpty
                    ? const Center(
                        child: Text('Belum ada tugas. Tambahkan tugas di menu Pengingat Tugas!'),
                      )
                    : ListView.builder(
                        itemCount: _tugas.length,
                        itemBuilder: (context, index) {
                          final tugas = _tugas[index];
                          return Card(
                            color: tugas.selesai
                                ? Colors.green[800]
                                : const Color(0xFF7494EC),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                tugas.judul,
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: tugas.selesai
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (tugas.mataKuliah != null)
                                    Text(
                                      'MK: ${tugas.mataKuliah}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  if (tugas.deskripsi != null && 
                                      tugas.deskripsi!.isNotEmpty)
                                    Text(
                                      'Desc: ${tugas.deskripsi}',
                                      style: const TextStyle(color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (tugas.deadline != null)
                                    Text(
                                      'Deadline: ${DateFormat('yyyy-MM-dd').format(tugas.deadline!)}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                ],
                              ),
                              leading: Checkbox(
                                value: tugas.selesai,
                                onChanged: (value) => _toggleSelesai(index),
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
