import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';

class AturJadwalPage extends StatefulWidget {
  const AturJadwalPage({super.key});

  @override
  _AturJadwalPageState createState() => _AturJadwalPageState();
}

class _AturJadwalPageState extends State<AturJadwalPage> {
  List<Jadwal> _jadwal = [];
  List<MataKuliah> _mataKuliah = [];
  
  int? _selectedMKId; // Gunakan ID bukan string
  String? _selectedMKName;
  String? _selectedHari;
  TimeOfDay? _selectedJamMulai;
  TimeOfDay? _selectedJamSelesai;
  String? _selectedRuangan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jadwalData = await DataManager.loadJadwal();
    final mkData = await DataManager.loadMataKuliah();
    
    // Load nama untuk setiap jadwal
    for (var j in jadwalData) {
      final mkWithName = mkData.firstWhere(
        (mk) => mk.id == j.idMatakuliah,
        orElse: () => MataKuliah(nama: 'Unknown', id: j.idMatakuliah),
      );
      j.mataKuliah = mkWithName.nama;
    }
    
    setState(() {
      _jadwal = jadwalData;
      _mataKuliah = mkData;
    });
  }

  Future<void> _selectJamMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedJamMulai ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedJamMulai) {
      setState(() {
        _selectedJamMulai = picked;
      });
    }
  }

  Future<void> _selectJamSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedJamSelesai ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedJamSelesai) {
      setState(() {
        _selectedJamSelesai = picked;
      });
    }
  }

  void _addJadwal() {
    if (_selectedMKId != null && _selectedHari != null && _selectedJamMulai != null && _selectedJamSelesai != null) {
      final jadwal = Jadwal(
        idMatakuliah: _selectedMKId,
        mataKuliah: _selectedMKName,
        hari: _selectedHari!,
        jamMulai: _selectedJamMulai!.format(context),
        jamSelesai: _selectedJamSelesai!.format(context),
        ruangan: _selectedRuangan,
      );
      
      DataManager.insertJadwal(jadwal).then((id) {
        jadwal.id = id;
        setState(() {
          _jadwal.add(jadwal);
          _resetForm();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field yang diperlukan')),
      );
    }
  }

  void _resetForm() {
    _selectedMKId = null;
    _selectedMKName = null;
    _selectedHari = null;
    _selectedJamMulai = null;
    _selectedJamSelesai = null;
    _selectedRuangan = null;
  }

  void _editJadwal(int index) {
    final jadwal = _jadwal[index];
    _selectedMKId = jadwal.idMatakuliah;
    _selectedMKName = jadwal.mataKuliah;
    _selectedHari = jadwal.hari;
    _selectedJamMulai = _timeOfDayFromString(jadwal.jamMulai);
    _selectedJamSelesai = _timeOfDayFromString(jadwal.jamSelesai);
    _selectedRuangan = jadwal.ruangan;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedMKId,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                  items: _mataKuliah.map((mk) {
                    return DropdownMenuItem(
                      value: mk.id,
                      child: Text(mk.nama),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      _selectedMKId = value;
                      if (value != null) {
                        _selectedMKName = _mataKuliah.firstWhere((mk) => mk.id == value).nama;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedHari,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
                      .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                      .toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      _selectedHari = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _selectJamMulai(context);
                    setStateDialog(() {});
                  },
                  child: Text(
                    _selectedJamMulai == null
                        ? 'Pilih Jam Mulai'
                        : _selectedJamMulai!.format(context),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _selectJamSelesai(context);
                    setStateDialog(() {});
                  },
                  child: Text(
                    _selectedJamSelesai == null
                        ? 'Pilih Jam Selesai'
                        : _selectedJamSelesai!.format(context),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: _selectedRuangan ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'Ruangan (opsional)',
                    prefixIcon: Icon(Icons.location_on, color: Color(0xFF7494EC)),
                  ),
                  onChanged: (value) {
                    _selectedRuangan = value.isNotEmpty ? value : null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedMKId != null &&
                    _selectedHari != null &&
                    _selectedJamMulai != null &&
                    _selectedJamSelesai != null) {
                  final updatedJadwal = Jadwal(
                    id: jadwal.id,
                    idMatakuliah: _selectedMKId,
                    mataKuliah: _selectedMKName,
                    hari: _selectedHari!,
                    jamMulai: _selectedJamMulai!.format(context),
                    jamSelesai: _selectedJamSelesai!.format(context),
                    ruangan: _selectedRuangan,
                  );
                  
                  DataManager.updateJadwal(updatedJadwal).then((_) {
                    setState(() {
                      _jadwal[index] = updatedJadwal;
                    });
                    Navigator.of(context).pop();
                    _resetForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jadwal berhasil diperbarui')),
                    );
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteJadwal(int index) {
    final jadwal = _jadwal[index];
    if (jadwal.id != null) {
      DataManager.deleteJadwal(jadwal.id!).then((_) {
        setState(() {
          _jadwal.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil dihapus')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      });
    }
  }

  TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atur Jadwal'), centerTitle: true),
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
              DropdownButtonFormField<int>(
                value: _selectedMKId,
                decoration: const InputDecoration(
                  labelText: 'Mata Kuliah',
                  prefixIcon: Icon(Icons.book, color: Color(0xFF7494EC)),
                ),
                items: _mataKuliah.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('Tidak ada mata kuliah'))]
                    : _mataKuliah.map((mk) {
                        return DropdownMenuItem(
                          value: mk.id,
                          child: Text(mk.nama),
                        );
                      }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMKId = value;
                    if (value != null) {
                      _selectedMKName = _mataKuliah.firstWhere((mk) => mk.id == value).nama;
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedHari,
                decoration: const InputDecoration(
                  labelText: 'Hari',
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF7494EC)),
                ),
                items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu']
                    .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHari = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectJamMulai(context),
                      child: Text(
                        _selectedJamMulai == null
                            ? 'Pilih Jam Mulai'
                            : _selectedJamMulai!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectJamSelesai(context),
                      child: Text(
                        _selectedJamSelesai == null
                            ? 'Pilih Jam Selesai'
                            : _selectedJamSelesai!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _selectedRuangan ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Ruangan (opsional)',
                  prefixIcon: Icon(Icons.location_on, color: Color(0xFF7494EC)),
                ),
                onChanged: (value) {
                  _selectedRuangan = value.isNotEmpty ? value : null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addJadwal,
                child: const Text('Tambah Jadwal'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _jadwal.isEmpty
                    ? const Center(
                        child: Text('Belum ada jadwal. Tambahkan jadwal baru!'),
                      )
                    : ListView.builder(
                        itemCount: _jadwal.length,
                        itemBuilder: (context, index) {
                          final jadwal = _jadwal[index];
                          return Card(
                            color: const Color(0xFF7494EC),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                jadwal.mataKuliah ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${jadwal.hari} | ${jadwal.jamMulai} - ${jadwal.jamSelesai}${jadwal.ruangan != null ? ' | ${jadwal.ruangan}' : ''}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () => _editJadwal(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _deleteJadwal(index),
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
}
