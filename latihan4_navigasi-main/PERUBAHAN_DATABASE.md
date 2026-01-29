# Dokumentasi Perubahan - Implementasi Database Offline

## Ringkasan
Aplikasi **Latihan 4 Navigasi** telah diubah untuk menyimpan semua data secara **offline ke database SQLite lokal**. Data yang diinput di setiap screen akan tersimpan dengan benar dan akan ditampilkan di dashboard dan screen lainnya.

## Perubahan Utama

### 1. **Data Models** (`lib/models/data_models.dart`)
Semua model data sekarang memiliki ID field untuk tracking ke database:

#### MataKuliah
```dart
class MataKuliah {
  int? id;              // ID database
  String nama;
  String? kode;
  int? sks;
  String? dosen;
}
```

#### Jadwal
```dart
class Jadwal {
  int? id;              // ID database
  int? idMatakuliah;    // Foreign key ke MataKuliah
  String? mataKuliah;   // Nama untuk display
  String hari;          // Senin, Selasa, dst
  String jamMulai;      // Format: HH:mm
  String jamSelesai;    // Format: HH:mm
  String? ruangan;
}
```

#### Tugas
```dart
class Tugas {
  int? id;              // ID database
  int? idMatakuliah;    // Foreign key ke MataKuliah
  String judul;
  String? deskripsi;
  DateTime? deadline;
  bool selesai;
  String? mataKuliah;   // Nama untuk display
}
```

#### Profil
```dart
class Profil {
  int? id;              // ID database
  String nama;
  String npm;
  String? email;
  String? noHp;
  String? prodi;
  int? semester;
}
```

### 2. **Data Manager** (`lib/models/data_manager.dart`)
Methods yang diperbaiki untuk handle insert, update, dan delete dengan database:

#### Mata Kuliah
- `loadMataKuliah()` - Load semua MK dengan ID dari database
- `insertMataKuliah(MataKuliah)` - Insert MK baru, return ID
- `updateMataKuliah(MataKuliah)` - Update MK yang sudah ada
- `deleteMataKuliah(int id)` - Delete MK berdasarkan ID

#### Jadwal
- `loadJadwal()` - Load semua jadwal dengan FK ke MK
- `loadJadwalByMataKuliah(int id)` - Load jadwal untuk MK tertentu
- `insertJadwal(Jadwal)` - Insert jadwal baru
- `updateJadwal(Jadwal)` - Update jadwal
- `deleteJadwal(int id)` - Delete jadwal

#### Tugas
- `loadTugas()` - Load semua tugas dengan FK ke MK
- `loadTugasByMataKuliah(int id)` - Load tugas untuk MK tertentu
- `insertTugas(Tugas)` - Insert tugas baru
- `updateTugas(Tugas)` - Update tugas
- `updateTugasStatus(int id, bool selesai)` - Toggle status selesai
- `deleteTugas(int id)` - Delete tugas

### 3. **Input Mata Kuliah Page** (`lib/screens/input_mk_page.dart`)
- ✅ Input tambahan: Kode, SKS, Nama Dosen
- ✅ Data langsung disimpan ke database saat tambah/edit/delete
- ✅ Tracking ID untuk setiap MK
- ✅ Error handling dengan SnackBar
- ✅ Empty state message jika belum ada data

### 4. **Atur Jadwal Page** (`lib/screens/atur_jadwal_page.dart`)
**Perubahan besar:**
- ❌ Tidak lagi menggunakan string nama MK
- ✅ Menggunakan `idMatakuliah` (foreign key) untuk relationship
- ✅ Dropdown mencari MK berdasarkan ID
- ✅ Data langsung disimpan ke database
- ✅ Dropdown hari dan jam yang proper
- ✅ Ruangan sebagai field opsional
- ✅ List view card yang lebih informatif

### 5. **Pengingat Tugas Page** (`lib/screens/pengingat_tugas_page.dart`)
**Perubahan besar:**
- ✅ Ubah nama field `deskripsi` → `judul` untuk sesuai database
- ✅ Tambah field `deskripsi` terpisah (opsional)
- ✅ Menggunakan `idMatakuliah` dan load nama dari MK
- ✅ Field deadline sebagai DateTime picker
- ✅ Data langsung disimpan ke database
- ✅ Toggle selesai langsung update database
- ✅ Edit/Delete dengan proper error handling

### 6. **Laporan Tugas Page** (`lib/screens/laporan_tugas_page.dart`)
**Perubahan:**
- ✅ Load data dari database dengan benar
- ✅ Tampilkan ringkasan: Total, Selesai, Belum Selesai
- ✅ Progress bar dengan percentage
- ✅ Toggle checkbox langsung update database
- ✅ Display MK nama, deskripsi, deadline
- ✅ Warna card berubah berdasarkan status (hijau = selesai, biru = belum)

### 7. **Dashboard Page** (`lib/screens/dashboard_page.dart`)
**Perubahan:**
- ✅ Load data dari database
- ✅ Refresh otomatis saat kembali dari screen lain (via `didChangeDependencies`)
- ✅ Tampilkan statistik: Total, Selesai, Belum Selesai, Progress %

## Database Schema

### Tabel: `matakuliah`
| Kolom | Tipe | Constraint |
|-------|------|-----------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| nama | TEXT | NOT NULL |
| kode | TEXT | - |
| sks | INTEGER | - |
| dosen | TEXT | - |
| tanggalDibuat | TEXT | - |

### Tabel: `jadwal`
| Kolom | Tipe | Constraint |
|-------|------|-----------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| idMatakuliah | INTEGER | FOREIGN KEY → matakuliah(id) |
| hari | TEXT | - |
| jamMulai | TEXT | - |
| jamSelesai | TEXT | - |
| ruangan | TEXT | - |

### Tabel: `tugas`
| Kolom | Tipe | Constraint |
|-------|------|-----------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| idMatakuliah | INTEGER | FOREIGN KEY → matakuliah(id) |
| judul | TEXT | NOT NULL |
| deskripsi | TEXT | - |
| deadline | TEXT | - |
| selesai | INTEGER | DEFAULT 0 |
| tanggalDibuat | TEXT | - |

### Tabel: `profil`
| Kolom | Tipe | Constraint |
|-------|------|-----------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| nama | TEXT | - |
| npm | TEXT | - |
| email | TEXT | - |
| noHp | TEXT | - |
| prodi | TEXT | - |
| semester | INTEGER | - |

## Fitur yang Sekarang Bekerja

✅ **Input Mata Kuliah** → Tersimpan di database, muncul di dropdown jadwal/tugas
✅ **Atur Jadwal** → Tersimpan dengan relationship ke MK, muncul di dashboard
✅ **Pengingat Tugas** → Tersimpan dengan relationship ke MK, muncul di laporan
✅ **Laporan Tugas** → Menampilkan statistik dan list tugas dari database
✅ **Dashboard** → Menampilkan ringkasan tugas dan statistik
✅ **Profil** → Tersimpan dan dimuat dari database
✅ **Data Persistence** → Data bertahan setelah app ditutup dan dibuka kembali
✅ **Offline Functionality** → Semua data disimpan lokal di device

## Cara Menggunakan

### 1. Input Mata Kuliah
- Buka "Input MK" dari drawer
- Isi Nama, Kode (opsional), SKS (opsional), Dosen (opsional)
- Klik "Tambah MK"
- Data tersimpan ke database ✓

### 2. Atur Jadwal
- Buka "Atur Jadwal" dari drawer
- Pilih MK dari dropdown (data dari database)
- Pilih hari, jam mulai, jam selesai
- Isi ruangan (opsional)
- Klik "Tambah Jadwal"
- Data tersimpan dengan relasi ke MK ✓

### 3. Pengingat Tugas
- Buka "Pengingat Tugas" dari drawer
- Isi judul tugas
- Isi deskripsi (opsional)
- Pilih MK (opsional)
- Pilih deadline (opsional)
- Klik "Tambah Tugas"
- Data tersimpan ke database ✓

### 4. Laporan Tugas
- Buka "Laporan Tugas" dari drawer
- Lihat ringkasan dan progress
- Checkbox untuk tandai selesai/belum
- Data otomatis terupdate

### 5. Dashboard
- Lihat ringkasan tugas
- Lihat pet yang tumbuh
- Refresh data dengan FAB

## Testing Offline

1. **Input data di semua screen** (Input MK, Jadwal, Tugas)
2. **Close aplikasi sepenuhnya** (force stop)
3. **Buka kembali aplikasi**
4. **Data harus masih ada** ✓

## Teknologi yang Digunakan

- **SQLite** via `sqflite` package
- **Foreign Keys** untuk relationship antar tabel
- **Singleton Pattern** di DatabaseHelper untuk manage koneksi
- **DateTime** handling untuk deadline
- **StatefulWidget** dengan proper state management

## Troubleshooting

### Data tidak tersimpan?
- Check apakah error ada saat klik "Tambah" atau "Simpan"
- Lihat LogCat/Console untuk error message
- Restart aplikasi dan coba lagi

### Dropdown MK kosong di Jadwal?
- Pastikan sudah input minimal 1 MK di "Input MK" screen
- Reload page dengan back-forth dari drawer

### Data hilang setelah menutup app?
- DatabaseHelper sudah implement singleton pattern dengan lazy init
- Pastikan tidak ada `closeDatabase()` yang dipanggil saat unnecessary

## File-file yang Diubah

1. ✅ `lib/models/data_models.dart` - Update model dengan ID fields
2. ✅ `lib/models/data_manager.dart` - Update CRUD methods
3. ✅ `lib/screens/input_mk_page.dart` - Full rewrite untuk database
4. ✅ `lib/screens/atur_jadwal_page.dart` - Full rewrite untuk database + FK
5. ✅ `lib/screens/pengingat_tugas_page.dart` - Full rewrite untuk database + FK
6. ✅ `lib/screens/laporan_tugas_page.dart` - Update untuk load dari database
7. ✅ `lib/screens/dashboard_page.dart` - Update untuk refresh data proper

## Catatan Penting

- Database file tersimpan di `/data/data/{package}/databases/app.db`
- Setiap kali app di-uninstall, database akan dihapus (normal behavior)
- Untuk development/testing: gunakan adb pull untuk akses database file
- Jika ada perubahan schema di masa depan, increment `version` di DatabaseHelper dan update `_onCreate`

---

**Status**: ✅ Semua fitur offline storage selesai dan teruji
**Last Updated**: January 25, 2026
