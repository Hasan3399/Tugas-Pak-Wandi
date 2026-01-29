import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../models/data_manager.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late Profil _profil;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DataManager.loadProfil();
    setState(() {
      _profil = data;
      _namaController.text = _profil.nama;
      _npmController.text = _profil.npm;
      _emailController.text = _profil.email ?? '';
      _noHpController.text = _profil.noHp ?? '';
      _prodiController.text = _profil.prodi ?? '';
      _semesterController.text = _profil.semester?.toString() ?? '';
    });
  }

  Future<void> _saveData() async {
    _profil = Profil(
      id: _profil.id,
      nama: _namaController.text,
      npm: _npmController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      noHp: _noHpController.text.isNotEmpty ? _noHpController.text : null,
      prodi: _prodiController.text.isNotEmpty ? _prodiController.text : null,
      semester: _semesterController.text.isNotEmpty 
          ? int.tryParse(_semesterController.text) 
          : null,
    );
    await DataManager.saveProfil(_profil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
          )
        ],
      ),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF7494EC),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _npmController,
                  decoration: const InputDecoration(
                    labelText: 'NPM',
                    prefixIcon: Icon(Icons.badge, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Opsional)',
                    prefixIcon: Icon(Icons.email, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noHpController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP (Opsional)',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _prodiController,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi (Opsional)',
                    prefixIcon: Icon(Icons.school, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Semester (Opsional)',
                    prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF7494EC)),
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('Simpan Profil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _npmController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _prodiController.dispose();
    _semesterController.dispose();
    super.dispose();
  }
}
