### Timeline Pengembangan MVP (6 Minggu) - Flutter

#### **Minggu 1: Setup, Autentikasi Dasar & Navigasi**

**Tujuan Minggu Ini:** Menyiapkan fondasi proyek Flutter, mengintegrasikan Firebase, dan membuat alur autentikasi pengguna berfungsi.

- **[ ] Setup Proyek:**

  - [ ] Buat proyek Flutter baru (`flutter create`).
  - [ ] Konfigurasikan dan integrasikan Firebase ke dalam proyek (iOS & Android).
  - [ ] Tambahkan dependensi Firebase yang dibutuhkan: `firebase_core`, `firebase_auth`, `cloud_firestore`.

- **[ ] UI & Fungsionalitas Autentikasi:**

  - [ ] Bangun UI untuk halaman **Login** dan **Registrasi**.
  - [ ] Implementasikan fungsionalitas registrasi dan login menggunakan **Firebase Authentication**.
  - [ ] Buat halaman **Splash Screen** untuk memeriksa status login pengguna saat aplikasi dibuka.

- **[ ] Arsitektur Aplikasi:**
  - [ ] Tentukan dan setup struktur folder proyek.
  - [ ] Implementasikan sistem navigasi/routing dasar (misal: menggunakan `Navigator 2.0` atau `go_router`).
  - [ ] Pilih dan setup state management (misal: **Provider**, **BLoC**, atau **Riverpod**) untuk mengelola state autentikasi.

---

#### **Minggu 2: Manajemen Bengkel & Pengguna**

**Tujuan Minggu Ini:** Mengimplementasikan alur "onboarding" di mana pengguna baru dapat membuat bengkel mereka sendiri.

- **[ ] Alur Onboarding:**

  - [ ] Setelah login, buat logika untuk memeriksa apakah pengguna sudah memiliki `workshopId`.
  - [ ] Jika tidak, arahkan pengguna ke halaman **"Buat Profil Bengkel Baru"**.
  - [ ] Buat UI form untuk membuat profil bengkel (Nama Bengkel, Alamat, dll).

- **[ ] Logika Backend:**
  - [ ] Implementasikan fungsi untuk menyimpan data bengkel baru ke koleksi `workshops`.
  - [ ] Setelah bengkel dibuat, update dokumen pengguna di koleksi `users` dengan `workshopId` yang baru dan berikan peran `owner`.
  - [ ] Buat halaman sederhana **"Profil Bengkel"** yang bisa diakses dari menu pengaturan.

---

#### **Minggu 3: CRUD Data Master (Pelanggan & Spare Part)**

**Tujuan Minggu Ini:** Membangun fitur inti untuk mengelola data pelanggan dan inventaris, yang akan menjadi dasar untuk Work Order.

- **[ ] Halaman Manajemen Pelanggan:**

  - [ ] Buat UI untuk menampilkan daftar pelanggan dalam bentuk `ListView`.
  - [ ] Buat halaman form untuk menambah/mengedit data pelanggan.
  - [ ] Implementasikan fungsionalitas CRUD (Create, Read, Update, Delete) untuk pelanggan.

- **[ ] Halaman Manajemen Spare Part:**

  - [ ] Buat UI untuk menampilkan daftar spare part.
  - [ ] Buat halaman form untuk menambah/mengedit data spare part (Nama, Harga Jual, Stok).
  - [ ] Implementasikan fungsionalitas CRUD untuk spare part.

- **[ ] Integrasi & Keamanan:**
  - [ ] Pastikan semua query Firestore **WAJIB** disaring berdasarkan `workshopId` pengguna yang sedang login.
  - [ ] Perkuat **Aturan Keamanan (Security Rules) Firestore** untuk melindungi koleksi `customers` dan `spare_parts`.

---

#### **Minggu 4: Alur Inti - Work Order (Pembuatan & Daftar)**

**Tujuan Minggu Ini:** Membangun fitur utama aplikasi, yaitu membuat dan melihat daftar Work Order.

- **[ ] Pembuatan Work Order:**

  - [ ] Rancang dan bangun UI untuk form **"Buat Work Order Baru"**.
  - [ ] Implementasikan dialog/halaman untuk **memilih pelanggan** dari data yang sudah ada.
  - [ ] Implementasikan fitur untuk **menambahkan item jasa** (input manual) dan **memilih spare part** dari inventaris.
  - [ ] Simpan data WO baru ke koleksi `work_orders` di Firestore dengan status awal.

- **[ ] Daftar Work Order:**
  - [ ] Buat halaman utama/dashboard untuk menampilkan daftar semua Work Order.
  - [ ] Gunakan `StreamBuilder` atau `FutureBuilder` untuk menampilkan data secara real-time.
  - [ ] Berikan opsi filter sederhana (misal: berdasarkan status).

---

#### **Minggu 5: Detail Work Order & Output (Nota PDF)**

**Tujuan Minggu Ini:** Menyelesaikan alur Work Order dan menghasilkan output yang dapat digunakan di dunia nyata.

- **[ ] Halaman Detail Work Order:**

  - [ ] Buat UI untuk menampilkan semua rincian dari sebuah Work Order.
  - [ ] Implementasikan fungsi untuk **mengubah status WO** (misal: dari "Dikerjakan" menjadi "Selesai").

- **[ ] Pembuatan & Pembagian Nota:**
  - [ ] Integrasikan library `pdf` untuk membuat dokumen PDF dari data WO.
  - [ ] Rancang template nota yang rapi.
  - [ ] Integrasikan library `share_plus` untuk menyediakan tombol **"Bagikan Nota"** (via WhatsApp, Email, dll).

---

#### **Minggu 6: Fitur Lanjutan, Penyempurnaan & Pengujian**

**Tujuan Minggu Ini:** Menambahkan fitur otomatisasi, memoles aplikasi, dan memastikan semuanya stabil.

- **[ ] Otomatisasi Stok:**

  - [ ] Tulis dan deploy **Cloud Function** yang akan dipicu saat status WO diubah menjadi `Dibayar`.
  - [ ] Fungsi ini akan membaca `parts` yang digunakan dalam WO dan mengurangi field `stock` di dokumen `spare_parts` yang sesuai.

- **[ ] UI/UX Polish & Penanganan Error:**

  - [ ] Tambahkan _loading indicator_ (`CircularProgressIndicator`) di semua layar yang mengambil data.
  - [ ] Tampilkan pesan error yang informatif kepada pengguna jika terjadi masalah koneksi atau lainnya.
  - [ ] Perbaiki bug-bug minor pada UI dan alur kerja.

- **[ ] Pengujian & Persiapan Rilis:**
  - [ ] Lakukan pengujian end-to-end dengan membuat dua akun dari bengkel yang berbeda untuk memastikan isolasi data berjalan sempurna.
  - [ ] Siapkan aset aplikasi (ikon, splash screen) untuk rilis.
  - [ ] Bangun versi rilis (`flutter build apk --release` dan `flutter build ipa`).
