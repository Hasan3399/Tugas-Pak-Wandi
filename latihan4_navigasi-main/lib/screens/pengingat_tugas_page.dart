import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';

class PengingatTugasPage extends StatefulWidget {
  const PengingatTugasPage({super.key});

  @override
  _PengingatTugasPageState createState() => _PengingatTugasPageState();
}

class _PengingatTugasPageState extends State<PengingatTugasPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  List<Tugas> _tugas = [];
  List<MataKuliah> _mataKuliah = [];
  
  int? _selectedMKId;
  DateTime? _selectedDeadline;

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
      
      DataManager.insertTugas(tugas).then((id) {
        tugas.id = id;
        if (_selectedMKId != null) {
          final mk = _mataKuliah.firstWhere((m) => m.id == _selectedMKId);
          tugas.mataKuliah = mk.nama;
        }
        setState(() {
          _tugas.add(tugas);
          _judulController.clear();
          _deskripsiController.clear();
          _selectedMKId = null;
          _selectedDeadline = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil ditambahkan')),
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
    final tugas = _tugas[index];
    if (tugas.id != null) {
      DataManager.deleteTugas(tugas.id!).then((_) {
        setState(() {
          _tugas.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil dihapus')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
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
                child: _tugas.isEmpty
                    ? const Center(
                        child: Text('Belum ada tugas. Tambahkan tugas baru!'),
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
