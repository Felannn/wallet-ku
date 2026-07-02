# Aplikasi Wallet Ku & Material Ku (Integrasi E-Commerce & E-Wallet)

* **Nama** : Felan Ardenta Yoga Adiyatama
* **NIM** : 1123150086
* **Kelas** : TI SE SH 23
* **Matkul** : Pemrograman Mobile Lanjutan
* **Kampus** : Global Institute Bina Sarana Global

Aplikasi ini dibuat bertujuan untuk memenuhi kebutuhan penilaian UAS Pemrograman Mobile Lanjutan pada semester 6 di Global Institute Bina Sarana Global.

---

## 📌 Deskripsi Sistem

Proyek ini merupakan integrasi ekosistem keuangan digital yang terdiri dari dua aplikasi utama (E-Commerce **Material Ku** dan E-Wallet **Wallet Ku**) didukung oleh arsitektur backend microservices berbasis Go (Gin-Gonic). 

Sistem ini mensimulasikan alur pembayaran e-commerce modern menggunakan mekanisme **Deep Linking (Custom URL Scheme)** antar aplikasi secara native di platform Android.

---

## 🏗️ Clean Architecture (Arsitektur Bersih)

Aplikasi **Wallet Ku** dibangun menggunakan pola **Clean Architecture** yang memisahkan kode menjadi 3 layer utama demi kemudahan pemeliharaan (*maintainability*), pengujian (*testability*), dan fleksibilitas pengembangan:

```
  ┌────────────────────────────────────────────────────────┐
  │                   PRESENTATION LAYER                   │
  │     (UI Pages, Widgets, BLoC State Management)         │
  └───────────────────────────┬────────────────────────────┘
                              │
                              ▼
  ┌────────────────────────────────────────────────────────┐
  │                      DOMAIN LAYER                      │
  │   (Entities, Use Cases, Repository Interfaces)         │
  │           *Pure Dart - Bebas Dependensi UI*            │
  └───────────────────────────▲────────────────────────────┘
                              │
                              │
  ┌────────────────────────────────────────────────────────┐
  │                       DATA LAYER                       │
  │  (Models, Data Sources, Repository Implementations)    │
  └────────────────────────────────────────────────────────┘
```

### 1. Domain Layer (Pusat Logika Bisnis)
Merupakan jantung dari aplikasi yang ditulis menggunakan *pure Dart* tanpa tergantung pada library UI (Flutter). Layer ini berisi:
* **Entities**: Objek bisnis inti (contoh: `UserEntity`, `AccountEntity`, `TransactionEntity`).
* **Use Cases**: Alur logika spesifik aplikasi (contoh: `GetAccountUseCase`, `TransferUseCase`, `VerifyPinUseCase`).
* **Repository Interfaces**: Kontrak/abstraksi data yang harus diimplementasikan oleh Data Layer.

### 2. Data Layer (Sumber Data & Repositori)
Bertanggung jawab atas pengambilan dan manipulasi data dari API eksternal atau penyimpanan lokal:
* **Models**: Struktur data JSON parser yang mewarisi properti dari Entities (contoh: `UserModel`, `AccountModel`).
* **Data Sources**: Penghubung langsung ke API/DB (contoh: `RemoteDataSource` menggunakan Dio, `SecureStorageDataSource` untuk JWT token).
* **Repository Implementations**: Implementasi kontrak dari Domain Layer yang mengoordinasikan aliran data.

### 3. Presentation Layer (Antarmuka Pengguna)
Layer visual yang berinteraksi langsung dengan pengguna:
* **UI Pages & Widgets**: Halaman tampilan aplikasi (contoh: `HomePage`, `PaymentDeeplinkPage`, `PinPage`).
* **BLoC (Business Logic Component)**: Pengelola State Management terstruktur untuk memisahkan UI dan logika presentasi (contoh: `AuthBloc`, `AccountBloc`, `PaymentBloc`).

---

## 📂 Struktur Folder Proyek

### 1. Aplikasi Wallet Ku (Clean Architecture)
Aplikasi dompet digital ini terstruktur dengan memisahkan domain bisnis, data, dan presentasi secara modular:
```text
wallet_ku/
├── lib/
│   ├── core/                      # Utilitas global dan konfigurasi aplikasi
│   │   ├── constants/             # Konstanta teks, ukuran, dan API
│   │   ├── router/                # Konfigurasi navigasi (GoRouter)
│   │   ├── services/              # Layanan callback deeplink & otentikasi lokal
│   │   │   ├── biometric_service.dart
│   │   │   └── deeplink_service.dart
│   │   └── theme/                 # Palet warna premium, tema, dan gaya teks
│   │
│   ├── data/                      # Implementasi operasional data (API/DB)
│   │   ├── datasources/           # Remote client (Dio) & local storage (Secure Storage)
│   │   ├── models/                # JSON parser & mapper untuk entitas
│   │   └── repositories/          # Implementasi kontrak repositori domain
│   │
│   ├── domain/                    # Layer bisnis murni (bebas dependensi UI)
│   │   ├── entities/              # Objek bisnis inti (User, Account, Transaction)
│   │   ├── repositories/          # Kontrak interface data (abstraksi)
│   │   └── usecases/              # Logika use-case spesifik aplikasi
│   │
│   ├── presentation/              # Layer visual antarmuka pengguna
│   │   ├── blocs/                 # Pengelola state aplikasi menggunakan BLoC
│   │   ├── pages/                 # Halaman aplikasi (home, payment, topup, transfer, success)
│   │   └── widgets/               # Komponen UI reusable (buttons, badges, pin_pad)
│   │
│   ├── injection/                 # Pengaturan Dependency Injection (GetIt/Locator)
│   ├── firebase_options.dart      # Konfigurasi Firebase untuk Android/iOS
│   └── main.dart                  # Titik entri utama aplikasi
```

### 2. Aplikasi Material Ku (Feature-First Architecture)
Aplikasi e-commerce ini dikelompokkan berdasarkan modul/fitur untuk mempermudah pengembangan modul:
```text
matrial_1123150086_uts/
├── lib/
│   ├── core/                      # Infrastruktur bersama & fungsi global
│   │   ├── constants/             # String konstan & parameter endpoint
│   │   ├── guards/                # Pelindung rute login / otentikasi (AuthGuard)
│   │   ├── routes/                # Tabel rute navigasi aplikasi
│   │   ├── services/              # Layanan backend HTTP, secure storage, & notifikasi
│   │   │   ├── biometric_service.dart
│   │   │   ├── dio_client.dart
│   │   │   └── notification_service.dart
│   │   ├── shared/                # Widget reusable lintas modul (buttons, fields, headers)
│   │   └── theme/                 # Pengaturan tema visual & warna
│   │
│   ├── features/                  # Modul fitur utama e-commerce
│   │   ├── auth/                  # Modul Otentikasi (Login, Register, Email Verification)
│   │   │   ├── presentation/
│   │   │   │   ├── pages/         # Tampilan halaman login, register, dll.
│   │   │   │   └── providers/     # Pengelola state otentikasi (AuthProvider)
│   │   │
│   │   ├── cart/                  # Modul Keranjang & Transaksi Checkout
│   │   │   ├── presentation/
│   │   │   │   ├── pages/         # Tampilan cart, checkout, success, awaiting_payment
│   │   │   │   └── providers/     # Pengelola state belanja & pembayaran
│   │   │
│   │   └── dashboard/             # Modul Dashboard utama (Home, History, Profile)
│   │       ├── presentation/
│   │       │   ├── pages/         # Tampilan dashboard, katalog produk, riwayat belanja
│   │       │   └── providers/     # Pengelola katalog produk
│   │
│   ├── firebase_options.dart      # Konfigurasi Firebase lokal
│   └── main.dart                  # Inisialisasi dependensi global & stream listener deeplink
```

---

## 🔄 Alur Integrasi Aplikasi (Application Flow)

Integrasi komunikasi antar-aplikasi (**Material Ku** ⇆ **Wallet Ku**) berjalan menggunakan skema **Android Custom Intents (Deeplinks)**:

### Diagram Sekuen Alur Pembayaran:

```
+--------------+           +--------------+          +-------------+          +-------------+
| Toko         |           | Sistem OS    |          | Aplikasi    |          | Go Backend  |
| Material Ku  |           | Android      |          | Wallet Ku   |          | Service     |
+------+-------+           +------+-------+          +------+------+          +------+------+
       |                          |                         |                        |
       | 1. Checkout Order        |                         |                        |
       |---------------------------------------------------------------------------->|
       |                          |                         |                        | (Buat Transaksi
       | 2. Kirim Link Pembayaran |                         |                        |  "Menunggu Pembayaran")
       |<----------------------------------------------------------------------------|
       | (dompetkampus://pay)     |                         |                        |
       |                          |                         |                        |
       | 3. Launch URL            |                         |                        |
       |------------------------->|                         |                        |
       |                          | 4. Buka Halaman Konfirmasi                      |
       |                          |------------------------>|                        |
       |                          |                         |                        |
       |                          |                         | 5. Request Akun/Saldo  |
       |                          |                         |----------------------->|
       |                          |                         |                        |
       |                          |                         | 6. Tampilkan Konfirmasi|
       |                          |                         |<-----------------------|
       |                          |                         | (Detail Nominal)       |
       |                          |                         |                        |
       +                          +                         +                        +
       |                          |                         |                        |
       |     [ JIKA USER PILIH BAYAR (INPUT PIN SUKSES) ]   |                        |
       |                          |                         |                        |
       |                          |                         | 7. Potong Saldo Akun   |
       |                          |                         |----------------------->|
       |                          |                         |                        |
       |                          |                         | 8. Respon Sukses       |
       |                          |                         |<-----------------------|
       |                          | 9. Callback Success     |                        |
       |                          |<------------------------|                        |
       |                          | (tokomaterial://callback)                        |
       | 10. Foreground & Respon  |                         |                        |
       |<-------------------------|                         |                        |
       |                          |                         |                        |
       | 11. Request backend untuk|                         |                        |
       |     update TRX "Selesai" |                         |                        |
       |---------------------------------------------------------------------------->|
       |                          |                         |                        |
       | 12. Pindah ke Halaman    |                         |                        |
       |     Sukses & Notifikasi  |                         |                        |
       |                          |                         |                        |
       +                          +                         +                        +
       |                          |                         |                        |
       |     [ JIKA USER PILIH BATAL (TEKAN TOMBOL X) ]     |                        |
       |                          |                         |                        |
       |                          | 7. Callback Cancelled   |                        |
       |                          |<------------------------|                        |
       |                          | (tokomaterial://callback)                        |
       | 8. Foreground & Respon   |                         |                        |
       |<-------------------------|                         |                        |
       | (Simpan status Pending di|                         |                        |
       |  History, kirim Silent   |                         |                        |
       |  Notification ke system) |                         |                        |
```

### 1. Fase Checkout (Toko Material)
* Saat checkout produk menggunakan metode **Wallet Ku**, Toko Material memanggil API Backend (`POST /v1/checkout`).
* Backend membuat transaksi baru di database dengan status `"Menunggu Pembayaran"` dan mengembalikan payload detail pembayaran.
* Toko Material meluncurkan URL Skema Khusus:
  `dompetkampus://pay?reference=TRX-XXXX&amount=XXXX&callback=tokomaterial://callback`

### 2. Fase Gateway Pembayaran (Wallet Ku)
* Sistem Android menangkap skema `dompetkampus://` dan mengarahkan pengguna secara native ke halaman `PaymentDeeplinkPage` di **Wallet Ku**.
* Wallet Ku menampilkan lembar konfirmasi berisi nama merchant, nomor referensi transaksi, dan nominal yang harus dibayar.
* Jika pengguna menekan tombol **Batal (X)**:
  * Wallet Ku mengirim callback status cancelled ke Merchant:
    `tokomaterial://callback?status=cancelled&reference=TRX-XXXX`
  * Aplikasi Wallet Ku kembali ke Beranda utama secara aman menggunakan `AppRouter.router.go('/home')`.
* Jika pengguna menekan tombol **Bayar**:
  * Pengguna diarahkan ke `PinPage` untuk memverifikasi keamanan (Sidik Jari / PIN).
  * Setelah PIN terverifikasi, Wallet Ku mengirim permintaan debit saldo ke API E-Money Backend.
  * Setelah saldo sukses terpotong, Wallet Ku mengirim callback status sukses ke Merchant:
    `tokomaterial://callback?status=success&reference=TRX-XXXX`

### 3. Fase Respon & Sinkronisasi (Toko Material)
* Sistem Android mengembalikan aplikasi **Toko Material** ke foreground saat mendeteksi skema `tokomaterial://callback`.
* Listener stream di `main.dart` mengurai parameter kembalian:
  * **Jika `status == success`**: Toko Material memanggil API callback backend untuk mengubah status pesanan di database menjadi `"Selesai"`, menampilkan **`PaymentSuccessPage`**, dan mengirimkan **Push Notification** suara sukses.
  * **Jika `status == cancelled`**: Toko Material membatalkan proses, membiarkan status pesanan tetap `"Menunggu Pembayaran"` agar bisa dibayar ulang lewat menu **History**, dan memicu **Silent Background Notification** yang masuk langsung ke Notification Drawer.


### Tampilan UI Aplikasi Material ku & Wallet ku

* Tampilan Aplikasi Wallet Ku :
<p align="center">
  <img src="assets/images/wallet1.jpeg" width="200"/>
  <img src="assets/images/wallet2.jpeg" width="200"/>
  <img src="assets/images/wallet3.jpeg" width="200"/>
  <img src="assets/images/wallet4.jpeg" width="200"/>
  <img src="assets/images/wallet5.jpeg" width="200"/>
  <img src="assets/images/wallet6.jpeg" width="200"/>
  <img src="assets/images/wallet7.jpeg" width="200"/>
  <img src="assets/images/wallet8.jpeg" width="200"/>
  <img src="assets/images/wallet9.jpeg" width="200"/>
  <img src="assets/images/wallet10.jpeg" width="200"/>
  <img src="assets/images/wallet11.jpeg" width="200"/>
  <img src="assets/images/wallet12.jpeg" width="200"/>
  <img src="assets/images/wallet13.jpeg" width="200"/>
</p>

* Tampilan Aplikasi Toko Material Ku:
<p align="center">
  <img src="assets/images/material1.jpeg" width="200"/>
  <img src="assets/images/material2.jpeg" width="200"/>
  <img src="assets/images/material3.jpeg" width="200"/>
  <img src="assets/images/material4.jpeg" width="200"/>
  <img src="assets/images/material5.jpeg" width="200"/>
  <img src="assets/images/material6.jpeg" width="200"/>
  <img src="assets/images/material7.jpeg" width="200"/>
  <img src="assets/images/material8.jpeg" width="200"/>
  <img src="assets/images/material9.jpeg" width="200"/>
  <img src="assets/images/material10.jpeg" width="200"/>
</p>

* Tampilan Ketika Aplikasi saling terhubung dengan deeplink

<p align="center">
  <img src="assets/images/deeplink1.jpeg" width="200"/>
  <img src="assets/images/deeplink2.jpeg" width="200"/>
  <img src="assets/images/deeplink3.jpeg" width="200"/>
  <img src="assets/images/deeplink4.jpeg" width="200"/>
  <img src="assets/images/deeplink5.jpeg" width="200"/>
  <img src="assets/images/deeplink6.jpeg" width="200"/>
  <img src="assets/images/deeplink7.jpeg" width="200"/>
</p>

### Github Repository

* [E-commerce Material Ku](https://github.com/Felannn/matrial_1123150086_uts.git) - Klik untuk melihat repositori E-Commerce

* [Wallet Ku](https://github.com/Felannn/wallet-ku.git) - Klik untuk melihat repositori E-Money Wallet

* [Backend E-Commerce](https://github.com/Felannn/gin-backend.git) - Klik untuk melihat repositori Backend Api E-commerce

* [Backend E-Money](https://github.com/Felannn/be-wallet-ku.git) - Klik untuk melihat repositori Backend Api E-Money

### Presentasi Youtube

* [Link Presentasi Youtube](https://youtu.com) - Klik untuk melihat presentasi Youtube
