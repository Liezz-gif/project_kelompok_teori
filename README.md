# 🍲 NgulinerLokal

> **Aplikasi Pemesanan Kuliner Lokal Khas Malang Berbasis Flutter**  
> Dibuat untuk memenuhi tugas proyek kelompok mata kuliah Pemrograman Berbasis Objek / Mobile.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=OpenStreetMap&logoColor=white)](https://www.openstreetmap.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

---

## 📖 Tentang Aplikasi

**NgulinerLokal** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah pecinta kuliner dalam menjelajah, memesan, dan melacak hidangan lokal khas Malang dan Jawa Timur (seperti Bakso Malang Komplit, Rawon Daging Sapi, Pecel Kawi, dan Soto Lombok).

Aplikasi ini mengintegrasikan **State Management terpusat (Provider)**, **peta interaktif (Flutter Map & OpenStreetMap)**, **pencarian alamat cerdas (Geocoding & Reverse Geocoding)**, **integrasi langsung ke Google Maps**, serta **fitur favorit dan profil dinamis**.

---

## ✨ Fitur-Fitur Utama

### 1. 🔐 Autentikasi & Sinkronisasi Profil Pengguna
* **Login Terintegrasi**: Pengguna dapat masuk menggunakan email dan kata sandi dengan validasi format email (`@`).
* **Sinkronisasi Profil Dinamis**: Nama dan email pada halaman profil secara otomatis tersinkronisasi sesuai input saat login (bukan data *default* statis).
* **Avatar & Edit Profil**: Menampilkan inisial nama pengguna secara otomatis serta modal dialog untuk memperbarui nama panggilan kapan saja.

### 2. 🍲 Katalog Kuliner & Menu Favorit
* **Daftar Kuliner Khas**: Menyajikan katalog kuliner lengkap dengan foto, nama, deskripsi mendalam, serta harga yang transparan.
* **Fitur Tambah ke Favorit (❤️)**: Tombol favorit interaktif langsung pada setiap kartu katalog kuliner dan halaman detail menu.
* **Halaman Menu Favorit Dinamis**: Tab profil menyajikan daftar menu yang disukai pengguna secara *real-time*, lengkap dengan opsi hapus favorit.

### 3. 🛒 Keranjang & Rekomendasi Alamat Cerdas
* **Manajemen Keranjang**: Tambah, kurangi kuantitas, dan hitung total pembayaran secara instan dengan *badge count* pada bilah navigasi.
* **Pencarian Alamat Pintar**:
  * Menggunakan database lokal Malang (mencakup kampus UB, UM, UMM, Polinema, asrama mahasiswa seperti Asrama Putra ISBA di Dau, serta jalan-jalan protokol).
  * Terintegrasi dengan pencarian online OpenStreetMap Nominatim dengan *debouncing* (350 ms).
  * Tombol **Pilihan Cepat** (*Asrama ISBA*, *Univ Brawijaya*, *Jl. Suhat*, *Jl. Veteran*).
* **Peta Interaktif dalam Keranjang**:
  * Pin lokasi GPS berpindah secara presisi mengikuti alamat yang dipilih.
  * Pengguna dapat **mengetuk titik mana saja di peta** untuk menyesuaikan lokasi pengantaran dengan fitur *reverse geocoding* otomatis.
* **Buka di Google Maps**: Membuka titik koordinat GPS presisi langsung di aplikasi Google Maps eksternal.
* **Layout Bebas Overflow**: Antarmuka responsif dengan *sticky bottom bar* yang rapi di berbagai resolusi layar.

### 4. 📍 Alamat Utama Pengiriman di Profil
* Mengatur alamat pengiriman utama pengguna yang otomatis tersinkronisasi ke formulir keranjang belanja.
* Pratinjau peta interaktif di lembar edit profil serta tombol pintasan langsung ke Google Maps.

### 5. 🛵 Pelacakan Pesanan Real-Time (Order Tracking)
* Menampilkan daftar pesanan aktif dengan status berkode warna: **Diproses** ➔ **Dikirim** ➔ **Selesai**.
* Dilengkapi peta visual titik koordinat tujuan yang dipilih pengguna saat checkout.
* Tombol simulasi perubahan status pengantaran makanan.

---

## 🛠️ Arsitektur & Teknologi

* **Framework**: Flutter 3 (Dart SDK ^3.13.2)
* **Pola Arsitektur**: Provider (State Management)
* **Paket Utama**:
  * `provider`: Manajemen state reaktif lintas widget (`MenuProvider`, `CartProvider`, `OrderProvider`, `UserProvider`).
  * `flutter_map` & `latlong2`: Visualisasi peta OpenStreetMap tanpa dependensi berbayar/API key.
  * `http`: Integrasi API Geocoding & Reverse Geocoding OpenStreetMap Nominatim.
  * `url_launcher`: Deep-linking membuka aplikasi Google Maps native.
  * `cupertino_icons`: Ikon grafis antarmuka.

---

## 📂 Struktur Direktori Proyek

```text
lib/
├── main.dart                      # Titik masuk utama aplikasi (MultiProvider & Theme)
├── models/                        # Model data objek
│   ├── cart_item_model.dart       # Model item keranjang belanja
│   ├── menu_model.dart            # Model kuliner
│   └── order_model.dart           # Model pesanan & koordinat tujuan
├── providers/                     # State management (ChangeNotifier)
│   ├── cart_provider.dart         # Logika penambahan/penghapusan keranjang
│   ├── menu_provider.dart         # Data menu & manajemen menu favorit (❤️)
│   ├── order_provider.dart        # Logika checkout & simulasi status pesanan
│   └── user_provider.dart         # Data pengguna aktif & alamat utama
├── screens/                       # Halaman / Tampilan Antarmuka
│   ├── cart_screen.dart           # Keranjang, alamat cerdas, peta interaktif & checkout
│   ├── detail_screen.dart         # Detail kuliner & tombol favorit
│   ├── home_screen.dart           # Katalog utama kuliner lokal
│   ├── login_screen.dart          # Halaman masuk & validasi email
│   ├── main_navigation_screen.dart# Navigasi bawah (Bottom Navigation Bar)
│   ├── profile_screen.dart        # Profil, favorit, riwayat, & edit alamat utama
│   └── tracking_screen.dart       # Pelacakan status pesanan & peta tujuan
├── services/
│   └── location_service.dart      # Database lokal Malang, Geocoding, & Reverse Geocoding
├── utils/
│   └── google_maps_helper.dart    # Utilitas membuka rute di Google Maps
└── widgets/                       # Komponen widget yang dapat digunakan ulang
    ├── cart_bottom_bar.dart       # Bar ringkasan keranjang melayang
    ├── embedded_google_map_view.dart # Widget peta interaktif & marker GPS
    └── food_image_widget.dart     # Penampil gambar menu dengan fallback
```

---

## 🚀 Panduan Menjalankan Proyek

### Prasyarat
* [Flutter SDK](https://flutter.dev/docs/get-started/install) terpasang di komputer.
* Android Studio / VS Code dengan ekstensi Flutter & Dart.
* Perangkat HP fisik Android (aktifkan USB Debugging) atau Android Emulator.

### Langkah Instalasi

1. **Clone Repository ini:**
   ```bash
   git clone https://github.com/Liezz-gif/project_kelompok_teori.git
   cd project_kelompok_teori
   ```

2. **Unduh Paket Dependensi:**
   ```bash
   flutter pub get
   ```

3. **Periksa Keselamatan Kode:**
   ```bash
   flutter analyze
   ```

4. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---

## 📦 Cara Membangun File APK Release

Untuk menghasilkan file APK siap pasang (*installer*) untuk pengumpulan tugas atau instalasi di HP Android:

```bash
flutter build apk --release
```

File APK release yang dihasilkan akan tersimpan di:
```text
build/app/outputs/flutter-apk/app-release.apk
```
*File APK ini dapat langsung dibagikan melalui WhatsApp, Google Drive, atau flashdisk untuk diinstal di perangkat pengguna.*

---

## 👥 Tim Pengembang

Proyek ini dikembangkan oleh kelompok mahasiswa:
* **Nama Tim**: Kelompok Teori Pemrograman Mobile
* **Repositori GitHub**: [Liezz-gif/project_kelompok_teori](https://github.com/Liezz-gif/project_kelompok_teori)

---

## 📄 Lisensi
Proyek ini dibuat untuk tujuan akademik dan pembelajaran. Bebas digunakan dan dimodifikasi untuk pengembangan lebih lanjut.
