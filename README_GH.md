# Latihan 4 Navigasi - Flutter Project

Aplikasi Flutter untuk manajemen jadwal dan tugas kuliah dengan navigasi yang baik.

## Fitur

- Dashboard dengan overview tugas
- Input mata kuliah baru
- Atur jadwal perkuliahan
- Pengingat tugas
- Laporan tugas
- Profil pengguna

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/
│   ├── data_manager.dart    # Pengelolaan data
│   ├── data_models.dart     # Model data
│   └── database_helper.dart # Database utilities
└── screens/
    ├── dashboard_page.dart       # Dashboard utama
    ├── home_page.dart           # Halaman rumah
    ├── input_mk_page.dart       # Input mata kuliah
    ├── atur_jadwal_page.dart    # Pengaturan jadwal
    ├── pengingat_tugas_page.dart # Pengingat tugas
    ├── laporan_tugas_page.dart  # Laporan tugas
    └── profil_page.dart         # Profil pengguna
```

## Persiapan

1. Pastikan Flutter SDK sudah terinstall
2. Clone repository ini
3. Jalankan `flutter pub get` untuk download dependencies
4. Jalankan `flutter run` untuk menjalankan aplikasi

## Persyaratan

- Flutter 3.0+
- Dart 2.18+
- Platform: Android, iOS, Web

## Development

Untuk development lebih lanjut:

```bash
# Get dependencies
flutter pub get

# Run app in development mode
flutter run

# Build release
flutter build apk  # untuk Android
flutter build ios  # untuk iOS
```

## Lihat juga

- [PERUBAHAN_DATABASE.md](PERUBAHAN_DATABASE.md) - Informasi perubahan database

---

Dikembangkan dengan ❤️ menggunakan Flutter
