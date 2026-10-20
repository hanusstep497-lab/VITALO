# Vitalo — Kebiasaan sehat, setiap hari

Aplikasi wellness harian berbasis **Flutter** untuk mencatat **tidur, air minum, dan gerak** dalam satu ritme sederhana.
Proyek ini dibuat berdasarkan proposal *Vitalo* (tugas mata kuliah, tahap **progress**).

> **Status: progress (belum final).** Seluruh data masih **dummy** (disimpan di memori, hilang saat aplikasi ditutup). Backend, login sungguhan, dan notifikasi asli belum diimplementasikan.

## Tampilan Aplikasi

Screenshot diambil dari emulator/perangkat. Simpan di folder `docs/screenshots/` dengan nama file sesuai tabel.

| 01 Splash & Login | 02 Home Dashboard | 03 Tambah Catatan |
| :---: | :---: | :---: |
| ![Login](docs/screenshots/01_login.png) | ![Home](docs/screenshots/02_home.png) | ![Tambah Catatan](docs/screenshots/03_tambah_catatan.png) |

| 04 Pelacak Kebiasaan | 05 Insight Progres | 06 Pengingat & Profil |
| :---: | :---: | :---: |
| ![Kebiasaan](docs/screenshots/04_kebiasaan.png) | ![Insight](docs/screenshots/05_insight.png) | ![Pengaturan](docs/screenshots/06_pengaturan.png) |

## Daftar Halaman (6 layar)

| No | Layar | File | Isi utama |
| --- | --- | --- | --- |
| 1 | Splash & Login | `lib/screens/splash_login_screen.dart` | Logo, tagline, tombol masuk Google/email (tampilan saja) |
| 2 | Home Dashboard | `lib/screens/home_screen.dart` | Progres air, tidur, langkah, progres harian, tombol tambah catatan |
| 3 | Tambah Catatan | `lib/screens/add_entry_screen.dart` | 3 tab: Tidur (durasi + kualitas), Air (quick-add), Aktivitas |
| 4 | Pelacak Kebiasaan | `lib/screens/habit_tracker_screen.dart` | Konsistensi mingguan, checklist target harian, streak |
| 5 | Insight Progres | `lib/screens/insight_screen.dart` | Grafik 7 hari, persentase konsistensi, pola, daftar insight |
| 6 | Pengingat & Profil | `lib/screens/settings_screen.dart` | Profil kesehatan, pengingat (switch + jam), kelola profil, keluar |

## Status Pengerjaan

| Fitur | Status |
| --- | --- |
| 6 halaman UI sesuai proposal | Selesai |
| Navigasi antar halaman (bottom navigation) | Selesai |
| State management (ChangeNotifier + InheritedNotifier) | Selesai |
| Pencatatan air/tidur/aktivitas memperbarui Home | Selesai (data dummy) |
| Penyimpanan permanen / backend | Belum |
| Login Google/email sungguhan | Belum |
| Notifikasi pengingat sungguhan | Belum |
| Badge, streak otomatis, insight dari data nyata | Belum |

## Struktur Proyek

```
lib/
├── main.dart                  # entry point + AppScope
├── theme.dart                 # palet warna & tema (sesuai proposal)
├── utils.dart                 # format angka, durasi, jam
├── state/app_state.dart       # AppState (data dummy) + AppScope
├── widgets/common.dart        # VCard, ProgressRing, ValueStepper
└── screens/                   # 6 layar + main_shell (bottom navigation)
test/widget_test.dart          # tes alur login -> home
```

## Cara Menjalankan

Repo ini berisi source code `lib/`, `test/`, dan `pubspec.yaml`. Folder platform (`android/`, `ios/`, dst.) dibuat otomatis oleh Flutter:

```bash
git clone <url-repo>
cd vitalo
flutter create . --project-name vitalo --platforms=android,ios,web
flutter pub get
flutter run
```

Menjalankan tes: `flutter test`

Tidak ada package pihak ketiga; hanya Flutter SDK (Dart >= 3.0).

## Palet Desain

| Peran | Warna |
| --- | --- |
| Forest (utama) | `#083C35` |
| Teal (aksen air/progres) | `#0FBDB7` |
| Orange (aksen highlight) | `#F26A3D` |
| Background | `#F2F4ED` |
