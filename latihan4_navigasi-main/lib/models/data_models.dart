class MataKuliah {
  int? id;
  String nama;
  String? kode;
  int? sks;
  String? dosen;

  MataKuliah({
    this.id,
    required this.nama,
    this.kode,
    this.sks,
    this.dosen,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kode': kode,
    'sks': sks,
    'dosen': dosen,
  };

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      sks: json['sks'],
      dosen: json['dosen'],
    );
  }
}

class Jadwal {
  int? id;
  int? idMatakuliah;
  String? mataKuliah; // Nama untuk display
  String hari;
  String jamMulai;
  String jamSelesai;
  String? ruangan;

  Jadwal({
    this.id,
    this.idMatakuliah,
    this.mataKuliah,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.ruangan,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idMatakuliah': idMatakuliah,
    'hari': hari,
    'jamMulai': jamMulai,
    'jamSelesai': jamSelesai,
    'ruangan': ruangan,
  };

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'],
      idMatakuliah: json['idMatakuliah'],
      mataKuliah: json['mataKuliah'],
      hari: json['hari'] ?? '',
      jamMulai: json['jamMulai'] ?? '',
      jamSelesai: json['jamSelesai'] ?? '',
      ruangan: json['ruangan'],
    );
  }
}

class Tugas {
  int? id;
  int? idMatakuliah;
  String judul;
  String? deskripsi;
  DateTime? deadline;
  bool selesai;
  String? mataKuliah; // Nama untuk display

  Tugas({
    this.id,
    this.idMatakuliah,
    required this.judul,
    this.deskripsi,
    this.deadline,
    this.selesai = false,
    this.mataKuliah,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idMatakuliah': idMatakuliah,
    'judul': judul,
    'deskripsi': deskripsi,
    'deadline': deadline?.toIso8601String(),
    'selesai': selesai ? 1 : 0,
    'mataKuliah': mataKuliah,
  };

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'],
      idMatakuliah: json['idMatakuliah'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      selesai: json['selesai'] == 1 ? true : false,
      mataKuliah: json['mataKuliah'],
    );
  }
}

class Profil {
  int? id;
  String nama;
  String npm;
  String? email;
  String? noHp;
  String? prodi;
  int? semester;

  Profil({
    this.id,
    required this.nama,
    required this.npm,
    this.email,
    this.noHp,
    this.prodi,
    this.semester,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'npm': npm,
    'email': email,
    'noHp': noHp,
    'prodi': prodi,
    'semester': semester,
  };

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: json['id'],
      nama: json['nama'] ?? '',
      npm: json['npm'] ?? '',
      email: json['email'],
      noHp: json['noHp'],
      prodi: json['prodi'],
      semester: json['semester'],
    );
  }
}
