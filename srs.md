# Spesifikasi Kebutuhan Perangkat Lunak (SKPL)

# Aplikasi Manajemen Bengkel (MVP) - Flutter

**Versi Dokumen:** 2.0  
**Tanggal:** 24 Mei 2025  
**Penyusun:** [M. Amirur Rizal]

---

## Daftar Isi

1.  [Pendahuluan](#1-pendahuluan)
    1.1. [Tujuan Dokumen](#11-tujuan-dokumen)
    1.2. [Ruang Lingkup Produk](#12-ruang-lingkup-produk)
    1.3. [Definisi, Akronim, dan Singkatan](#13-definisi-akronim-dan-singkatan)
    1.4. [Referensi](#14-referensi)
    1.5. [Ikhtisar Dokumen](#15-ikhtisar-dokumen)
2.  [Deskripsi Keseluruhan](#2-deskripsi-keseluruhan)
    2.1. [Perspektif Produk](#21-perspektif-produk)
    2.2. [Fungsi Produk (Ringkasan MVP)](#22-fungsi-produk-ringkasan-mvp)
    2.3. [Karakteristik Pengguna](#23-karakteristik-pengguna)
    2.4. [Batasan Umum](#24-batasan-umum)
    2.5. [Asumsi dan Ketergantungan](#25-asumsi-dan-ketergantungan)
3.  [Arsitektur & Model Data (Single Database)](#3-arsitektur--model-data-single-database)
    3.1. [Model Isolasi Data](#31-model-isolasi-data)
    3.2. [Identifikasi Pengguna & Bengkel](#32-identifikasi-pengguna--bengkel)
    3.3. [Provisioning Bengkel](#33-provisioning-bengkel)
4.  [Persyaratan Spesifik (MVP)](#4-persyaratan-spesifik-mvp)
    4.1. [Persyaratan Fungsional](#41-persyaratan-fungsional)
    4.2. [Persyaratan Antarmuka Pengguna (UI/UX)](#42-persyaratan-antarmuka-pengguna-uiux)
    4.3. [Persyaratan Database (Skema di Firestore)](#43-persyaratan-database-skema-di-firestore)
    4.4. [Persyaratan Non-Fungsional](#44-persyaratan-non-fungsional)
5.  [Fitur yang Tidak Termasuk dalam MVP](#5-fitur-yang-tidak-termasuk-dalam-mvp)

---

## 1. Pendahuluan

### 1.1. Tujuan Dokumen

Dokumen ini bertujuan untuk mendefinisikan dan menjelaskan kebutuhan fungsional dan non-fungsional untuk versi _Minimum Viable Product_ (MVP) dari Aplikasi Manajemen Bengkel. Dokumen ini akan menjadi acuan bagi tim pengembang dalam merancang, mengembangkan, dan menguji aplikasi.

### 1.2. Ruang Lingkup Produk

Aplikasi Manajemen Bengkel adalah sebuah **aplikasi mobile cross-platform (untuk iOS dan Android)** yang dirancang untuk membantu pemilik dan staf bengkel dalam mengelola operasional harian. MVP ini akan fokus pada fitur inti yang memungkinkan pencatatan order servis, manajemen pelanggan, inventaris spare part, dan pembuatan nota. Aplikasi akan dibangun menggunakan **satu database Firestore**, di mana data dari semua bengkel **diisolasi secara logis** menggunakan ID unik per bengkel.
Frontend akan dikembangkan menggunakan **Flutter**, dan backend akan memanfaatkan **Firebase (Firestore, Firebase Authentication, Cloud Functions)** sebagai _Backend as a Service_ (BaaS).

### 1.3. Definisi, Akronim, dan Singkatan

| Akronim        | Deskripsi                                                             |
| :------------- | :-------------------------------------------------------------------- |
| **SKPL**       | Spesifikasi Kebutuhan Perangkat Lunak                                 |
| **MVP**        | Minimum Viable Product                                                |
| **BaaS**       | Backend as a Service                                                  |
| **UI/UX**      | User Interface / User Experience                                      |
| **CRUD**       | Create, Read, Update, Delete                                          |
| **WO**         | Work Order (Order Servis)                                             |
| **workshopId** | ID unik yang merepresentasikan satu entitas bengkel di dalam database |

### 1.4. Referensi

- Diskusi dan kesepakatan fitur MVP dengan stakeholder.
- Dokumentasi Flutter (flutter.dev)
- Dokumentasi Firebase (firebase.google.com)

### 1.5. Ikhtisar Dokumen

Dokumen ini menguraikan arsitektur aplikasi mobile dengan backend Firebase, mendefinisikan persyaratan fungsional dan non-fungsional, serta mengklarifikasi fitur yang termasuk dan tidak termasuk dalam MVP.

---

## 2. Deskripsi Keseluruhan

### 2.1. Perspektif Produk

Aplikasi ini adalah produk baru yang akan didistribusikan melalui **Google Play Store** dan **Apple App Store**. Aplikasi ini menggunakan Firebase sebagai backend terintegrasi untuk menangani semua data, autentikasi, dan logika sisi server.

### 2.2. Fungsi Produk (Ringkasan MVP)

MVP akan menyediakan fungsi-fungsi inti berikut:

1.  **Manajemen Bengkel & Pengguna:** Registrasi, login, pembuatan profil bengkel, dan manajemen peran staf dasar.
2.  **Manajemen Order Servis:** Membuat, mencatat detail, dan memperbarui status pengerjaan servis.
3.  **Manajemen Pelanggan:** Menambah dan melihat daftar pelanggan milik bengkel.
4.  **Manajemen Inventaris Spare Part:** Menambah dan melihat daftar spare part beserta stok dan harga.
5.  **Manajemen Invoice & Pembayaran:** Membuat nota/invoice dari order servis dan mencatat pembayaran.

### 2.3. Karakteristik Pengguna

Pengguna utama aplikasi ini adalah:

1.  **Owner/Admin Bengkel:** Akan mendaftar, membuat profil bengkel, dan mengelola staf serta data bengkelnya.


### 2.4. Batasan Umum

- Aplikasi dikembangkan menggunakan **Flutter** untuk iOS dan Android.
- Backend menggunakan **Firebase**.
- Semua data disimpan dalam **satu database Firestore**, dengan isolasi data diimplementasikan melalui `workshopId` dan **Aturan Keamanan (Security Rules)**.
- Membutuhkan koneksi internet untuk sinkronisasi data.

### 2.5. Asumsi dan Ketergantungan

- Pengguna memiliki smartphone (iOS/Android) dan familiar dengan penggunaan aplikasi mobile.
- Layanan Firebase tersedia dan stabil.

---

## 3. Arsitektur & Model Data (Single Database)

### 3.1. Model Isolasi Data

Isolasi data antar bengkel dicapai secara logis, bukan fisik.

- **Satu Database:** Semua data dari semua bengkel akan disimpan dalam satu instance Firestore.
- **Pemisahan dengan `workshopId`:** Setiap dokumen yang spesifik untuk satu bengkel (seperti pelanggan, spare part, work order) **wajib** memiliki sebuah field bernama `workshopId`.
- **Keamanan dengan Security Rules:** Aturan Keamanan di Firestore akan menjadi garda terdepan. Aturan ini akan memastikan bahwa setiap permintaan baca/tulis hanya diizinkan jika `workshopId` pada data yang diminta cocok dengan `workshopId` yang ada di token autentikasi pengguna.

### 3.2. Identifikasi Pengguna & Bengkel

Setiap pengguna yang terautentikasi akan memiliki data profil di koleksi `users`. Data ini menyimpan `workshopId` tempat pengguna tersebut bekerja. Saat login, aplikasi akan mengambil `workshopId` ini dan menggunakannya untuk semua query data selanjutnya.

### 3.3. Provisioning Bengkel

Tidak ada proses provisioning manual oleh admin sistem. Alurnya terintegrasi ke dalam aplikasi:

1.  Pengguna baru mendaftar.
2.  Aplikasi memeriksa apakah pengguna sudah tergabung dalam sebuah bengkel.
3.  Jika tidak, aplikasi akan menampilkan opsi **"Buat Bengkel Baru"**.
4.  Saat bengkel dibuat, sistem menghasilkan `workshopId` unik, membuat dokumen di koleksi `workshops`, dan menautkan `workshopId` tersebut ke profil pengguna yang membuatnya (dengan peran `owner`).

---

## 4. Persyaratan Spesifik (MVP)

### 4.1. Persyaratan Fungsional

#### 4.1.1. FR-001: Manajemen Pengguna & Bengkel

- **FR-001.1: Registrasi & Login:** Sistem harus menyediakan form registrasi dan login menggunakan email/password via Firebase Authentication.
- **FR-001.2: Pembuatan Bengkel:** Sistem harus memungkinkan pengguna baru untuk membuat profil bengkel (Nama, Alamat). Proses ini akan menghasilkan `workshopId` baru.
- **FR-001.3: Manajemen Peran (Dasar):** Sistem harus bisa membedakan peran `owner` dan `mechanic`. Owner dapat mengundang staf baru ke bengkelnya (fitur undangan bisa via email atau kode unik).

#### 4.1.2. FR-002: Manajemen Order Servis (Work Order)

- **FR-002.1: Pembuatan WO:** Sistem harus memungkinkan pengguna membuat WO baru dengan informasi Pelanggan, Kendaraan, dan Keluhan.
- **FR-002.2: Pencatatan Detail WO:** Pengguna harus bisa menambahkan/menghapus item Jasa dan Spare Part ke dalam WO.
- **FR-002.3: Update Status WO:** Status WO dapat diubah (`Antrian`, `Dikerjakan`, `Selesai`, `Dibayar`).

#### 4.1.3. FR-003: Manajemen Pelanggan

- **FR-003.1: CRUD Pelanggan:** Sistem harus menyediakan fungsi CRUD untuk data pelanggan bengkel (Nama, No. Telepon, Alamat).
- **FR-003.2: Riwayat Servis:** Saat melihat detail pelanggan, sistem harus menampilkan daftar WO yang pernah dilakukan untuk pelanggan tersebut.

#### 4.1.4. FR-004: Manajemen Inventaris

- **FR-004.1: CRUD Spare Part:** Sistem harus menyediakan fungsi CRUD untuk data spare part (Nama, Harga Jual, Stok).
- **FR-004.2: Penyesuaian Stok Otomatis:** Saat status WO diubah menjadi `Dibayar`, stok spare part yang digunakan harus berkurang secara otomatis (diimplementasikan via Cloud Function).

#### 4.1.5. FR-005: Manajemen Invoice & Pembayaran

- **FR-005.1: Pembuatan Nota/Invoice:** Sistem harus dapat menghasilkan tampilan nota dari data WO yang "Selesai".
- **FR-005.2: Buat & Bagikan Nota (PDF):** Sistem harus bisa mengkonversi tampilan nota menjadi file PDF yang dapat dibagikan melalui WhatsApp, Email, dll.

### 4.2. Persyaratan Antarmuka Pengguna (UI/UX)

- **UI-001: Desain UI/UX untuk Mobile:** Antarmuka harus dirancang secara _mobile-first_, intuitif, dan mudah dinavigasi dengan sentuhan.
- **UI-002: Konsistensi:** Mengikuti panduan desain platform (Material Design untuk Android, Cupertino untuk iOS) untuk memberikan pengalaman yang familiar.
- **UI-003: Umpan Balik:** Memberikan umpan balik visual yang jelas seperti _loading indicators_, notifikasi sukses, dan pesan error yang informatif.

### 4.3. Persyaratan Database (Skema di Firestore)

Struktur koleksi utama berada di level root. Setiap dokumen yang relevan memiliki field `workshopId`.

- **Koleksi `workshops`**: Menyimpan profil setiap bengkel.
  ```json
  // /workshops/{workshopId}
  { "workshopName": "Bengkel Maju Mundur", "ownerUid": "abc123xyz" }
  ```
- **Koleksi `users`**: Menyimpan data pengguna dan tautan ke bengkel mereka.
  ```json
  // /users/{authUid}
  {
    "email": "staff@bengkel.com",
    "workshopId": "ws_maju_mundur",
    "role": "mechanic"
  }
  ```
- **Koleksi `customers`**: Menyimpan data pelanggan, terikat pada bengkel.
  ```json
  // /customers/{customerId}
  {
    "workshopId": "ws_maju_mundur",
    "customerName": "John Doe",
    "phoneNumber": "081..."
  }
  ```
- **Koleksi `spare_parts`**: Menyimpan inventaris, terikat pada bengkel.
  ```json
  // /spare_parts/{partId}
  {
    "workshopId": "ws_maju_mundur",
    "partName": "Busi Iridium",
    "sellPrice": 90000,
    "stock": 15
  }
  ```
- **Koleksi `work_orders`**: Menyimpan data transaksi, terikat pada bengkel.
  ```json
  // /work_orders/{woId}
  { "workshopId": "ws_maju_mundur", "status": "Selesai", "totalAmount": 150000, "customer": {...} }
  ```

### 4.4. Persyaratan Non-Fungsional

- **NF-001: Kinerja:** Aplikasi harus terasa responsif. Pemanfaatan cache offline dari Firestore untuk data yang sering diakses.
- **NF-002: Keamanan:** Isolasi data antar bengkel harus dijamin oleh **Aturan Keamanan Firestore**. Semua data sensitif harus dilindungi.
- **NF-003: Ketersediaan:** Mengandalkan uptime tinggi dari layanan Firebase.
- **NF-004: Keterpeliharaan (Maintainability):** Kode Flutter harus diorganisir dengan baik (misalnya, mengikuti arsitektur seperti BLoC/Riverpod) dan mudah dipelihara.

---

## 5. Fitur yang Tidak Termasuk dalam MVP

Berikut adalah fitur-fitur yang secara sadar **tidak** akan dimasukkan dalam rilis MVP ini:

- Dashboard analitik dan laporan keuangan canggih.
- Manajemen pembelian dari supplier.
- Penjadwalan mekanik dan kalender bengkel.
- Sistem notifikasi otomatis (push notification) ke pelanggan.
- Fitur booking online.
- Integrasi dengan payment gateway.
- Mode offline penuh (hanya caching dasar dari Firestore).

---

_Dokumen ini akan ditinjau dan diperbarui jika ada perubahan kebutuhan selama siklus pengembangan._
