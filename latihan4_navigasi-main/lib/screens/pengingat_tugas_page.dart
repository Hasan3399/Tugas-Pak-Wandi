import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';
import '../models/tugas_state_notifier.dart';

class PengingatTugasPage extends StatefulWidget {
  const PengingatTugasPage({super.key});

  @override
  _PengingatTugasPageState createState() => _PengingatTugasPageState();
}

class _PengingatTugasPageState extends State<PengingatTugasPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  late TugasStateNotifier _tugasNotifier;
  List<MataKuliah> _mataKuliah = [];
  
  int? _selectedMKId;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _tugasNotifier = TugasStateNotifier();
    _tugasNotifier.addListener(_onTugasChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tugasNotifier.removeListener(_onTugasChanged);
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _onTugasChanged() {
    setState(() {
      // Rebuild ketika ada perubahan di TugasStateNotifier
    });
  }

  Future<void> _loadData() async {
    await _tugasNotifier.loadTugas();
    final mkData = await DataManager.loadMataKuliah();
    
    setState(() {
      _mataKuliah = mkData;
    });
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _addTugas() {
    if (_judulController.text.isNotEmpty) {
      final tugas = Tugas(
        idMatakuliah: _selectedMKId,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text.isNotEmpty 
            ? _deskripsiController.text 
            : null,
        deadline: _selectedDeadline,
      );
      
      _tugasNotifier.addTugas(tugas).then((_) {
        if (_selectedMKId != null) {
          final mk = _mataKuliah.firstWhere((m) => m.id == _selectedMKId);
          tugas.mataKuliah = mk.nama;
        }
        _judulController.clear();
        _deskripsiController.clear();
        _selectedMKId = null;
        _selectedDeadline = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Tugas berhasil ditambahkan')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong')),
      );
    }
  }

  void _editTugas(int index) {
    final tugas = _tugas[index];
    _judulController.text = tugas.judul;
    _deskripsiController.text = tugas.deskripsi ?? '';
    _selectedMKId = tugas.idMatakuliah;
    _selectedDeadline = tugas.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Tugas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul Tugas'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedMKId,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah (Opsional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Pilih Mata Kuliah')),
                    ..._mataKuliah.map((mk) {
                      return DropdownMenuItem(
                        value: mk.id,
                        child: Text(mk.nama),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      _selectedMKId = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _selectDeadline(context);
                    setStateDialog(() {});
                  },
                  child: Text(
                    _selectedDeadline == null
                        ? 'Pilih Deadline'
                        : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _judulController.clear();
                _deskripsiController.clear();
                _selectedMKId = null;
                _selectedDeadline = null;
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final updatedTugas = Tugas(
                  id: tugas.id,
                  idMatakuliah: _selectedMKId,
                  judul: _judulController.text,
                  deskripsi: _deskripsiController.text.isNotEmpty 
                      ? _deskripsiController.text 
                      : null,
                  deadline: _selectedDeadline,
                  selesai: tugas.selesai,
                );
                
                DataManager.updateTugas(updatedTugas).then((_) {
                  if (_selectedMKId != null) {
                    final mk = _mataKuliah.firstWhere((m) => m.id == _selectedMKId);
                    updatedTugas.mataKuliah = mk.nama;
                  }
                  setState(() {
                    _tugas[index] = updatedTugas;
                  });
                  Navigator.of(context).pop();
                  _judulController.clear();
                  _deskripsiController.clear();
                  _selectedMKId = null;
                  _selectedDeadline = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tugas berhasil diperbarui')),
                  );
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTugas(int index) {
    final tugas = _tugasNotifier.tugas[index];
    if (tugas.id != null) {
      _tugasNotifier.deleteTugas(tugas.id!).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Tugas berhasil dihapus')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
  }

  void _toggleSelesai(int index) {
    final tugas = _tugasNotifier.tugas[index];
    final newStatus = !tugas.selesai;
    
    if (tugas.id != null) {
      _tugasNotifier.updateTugasStatus(tugas.id!, newStatus).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? '✓ Tugas ditandai selesai' : '○ Tugas ditandai belum selesai',
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Tugas'), centerTitle: true),
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
            children: [
              TextField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: Icon(Icons.task, color: Color(0xFF7494EC)),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  prefixIcon: Icon(Icons.description, color: Color(0xFF7494EC)),
                ),
                style: const TextStyle(color: Colors.black),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedMKId,
                decoration: const InputDecoration(
                  labelText: 'Mata Kuliah (Opsional)',
                  prefixIcon: Icon(Icons.book, color: Color(0xFF7494EC)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Pilih Mata Kuliah')),
                  ..._mataKuliah.map((mk) {
                    return DropdownMenuItem(
                      value: mk.id,
                      child: Text(mk.nama),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMKId = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDeadline(context),
                child: Text(
                  _selectedDeadline == null
                      ? 'Pilih Deadline'
                      : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTugas,
                child: const Text('Tambah Tugas'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _tugasNotifier.tugas.isEmpty
                    ? const Center(
                        child: Text('Belum ada tugas. Tambahkan tugas baru!'),
                      )
                    : ListView.builder(
                        itemCount: _tugasNotifier.tugas.length,
                        itemBuilder: (context, index) {
                          final tugas = _tugasNotifier.tugas[index];
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
                                  if (tugas.deskripsi != null && tugas.deskripsi!.isNotEmpty)
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
                                activeColor: const Color(0xFF7494EC),
                                checkColor: Colors.white,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () => _editTugas(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _deleteTugas(index),
                                  ),
                                ],
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

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}
