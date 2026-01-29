import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';

class InputMKPage extends StatefulWidget {
  const InputMKPage({super.key});

  @override
  _InputMKPageState createState() => _InputMKPageState();
}

class _InputMKPageState extends State<InputMKPage> {
  final TextEditingController _mkController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _sksController = TextEditingController();
  final TextEditingController _dosenController = TextEditingController();
  
  List<MataKuliah> _mataKuliah = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadDataIfNeeded();
  }

  Future<void> _loadDataIfNeeded() async {
    if (_isInitialized) return; // Skip if already loaded
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('[InputMK] Starting load...');
      if (mounted) setState(() => _isLoading = true);
      
      final startTime = DateTime.now();
      final data = await DataManager.loadMataKuliah();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[InputMK] Data loaded in ${duration}ms');
      
      if (mounted) {
        setState(() {
          _mataKuliah = data;
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('[InputMK] Error load: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error load: ${e.toString()}')),
        );
      }
    }
  }

  void _addMK() {
    if (_mkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama mata kuliah tidak boleh kosong')),
      );
      return;
    }

    if (_isLoading) {
      print('[InputMK] Ignoring double-click (loading)');
      return;
    }

    final mk = MataKuliah(
      nama: _mkController.text,
      kode: _kodeController.text.isNotEmpty ? _kodeController.text : null,
      sks: _sksController.text.isNotEmpty ? int.tryParse(_sksController.text) : null,
      dosen: _dosenController.text.isNotEmpty ? _dosenController.text : null,
    );
    
    print('[InputMK] Adding: ${mk.nama}');
    if (mounted) setState(() => _isLoading = true);

    final startTime = DateTime.now();
    DataManager.insertMataKuliah(mk).then((id) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[InputMK] Inserted in ${duration}ms');
      
      if (mounted) {
        mk.id = id;
        setState(() {
          _mataKuliah.add(mk);
          _mkController.clear();
          _kodeController.clear();
          _sksController.clear();
          _dosenController.clear();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Mata kuliah berhasil ditambahkan'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }).catchError((e) {
      print('[InputMK] Error insert MK: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _editMK(int index) {
    final mk = _mataKuliah[index];
    _mkController.text = mk.nama;
    _kodeController.text = mk.kode ?? '';
    _sksController.text = mk.sks?.toString() ?? '';
    _dosenController.text = mk.dosen ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Mata Kuliah'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mkController,
                decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
              ),
              TextField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode'),
              ),
              TextField(
                controller: _sksController,
                decoration: const InputDecoration(labelText: 'SKS'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dosenController,
                decoration: const InputDecoration(labelText: 'Dosen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _mkController.clear();
              _kodeController.clear();
              _sksController.clear();
              _dosenController.clear();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (_mkController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }

              final updatedMK = MataKuliah(
                id: mk.id,
                nama: _mkController.text,
                kode: _kodeController.text.isNotEmpty ? _kodeController.text : null,
                sks: _sksController.text.isNotEmpty ? int.tryParse(_sksController.text) : null,
                dosen: _dosenController.text.isNotEmpty ? _dosenController.text : null,
              );
              
              DataManager.updateMataKuliah(updatedMK).then((_) {
                setState(() {
                  _mataKuliah[index] = updatedMK;
                });
                Navigator.of(context).pop();
                _mkController.clear();
                _kodeController.clear();
                _sksController.clear();
                _dosenController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Mata kuliah berhasil diperbarui'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }).catchError((e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error: ${e.toString()}')),
                );
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteMK(int index) {
    final mk = _mataKuliah[index];
    if (mk.id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin hapus "${mk.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DataManager.deleteMataKuliah(mk.id!).then((_) {
                setState(() {
                  _mataKuliah.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Mata kuliah berhasil dihapus'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error: ${e.toString()}')),
                );
              });
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Mata Kuliah'), centerTitle: true),
      body: _isLoading && _mataKuliah.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                controller: _mkController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  prefixIcon: Icon(Icons.book, color: Color(0xFF7494EC)),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _kodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Mata Kuliah',
                  prefixIcon: Icon(Icons.code, color: Color(0xFF7494EC)),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sksController,
                decoration: const InputDecoration(
                  labelText: 'SKS',
                  prefixIcon: Icon(Icons.numbers, color: Color(0xFF7494EC)),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dosenController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dosen',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF7494EC)),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addMK,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Menyimpan...' : 'Tambah MK'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _mataKuliah.isEmpty
                    ? const Center(
                        child: Text('Belum ada mata kuliah. Tambahkan mata kuliah baru!'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _mataKuliah.length,
                          itemBuilder: (context, index) {
                            final mk = _mataKuliah[index];
                            return Card(
                              color: const Color(0xFF7494EC),
                              child: ListTile(
                                title: Text(
                                  mk.nama,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${mk.kode ?? 'Tanpa Kode'} - ${mk.sks ?? 0} SKS - ${mk.dosen ?? 'Tanpa Dosen'}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      onPressed: () => _editMK(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      onPressed: () => _deleteMK(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
    _mkController.dispose();
    _kodeController.dispose();
    _sksController.dispose();
    _dosenController.dispose();
    super.dispose();
  }
}
