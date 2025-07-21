# MyBengkel - Aplikasi Manajemen Bengkel

Aplikasi Flutter untuk manajemen bengkel yang memudahkan pemilik bengkel dalam mengelola pelanggan, spare part, work order, dan laporan keuangan.

## Fitur Utama

### 1. Autentikasi & Manajemen Bengkel

- Login dan registrasi pengguna
- Pembuatan profil bengkel baru
- Manajemen profil bengkel

### 2. Manajemen Pelanggan

- Tambah, edit, dan hapus data pelanggan
- Riwayat transaksi pelanggan
- Pencarian dan filter pelanggan

### 3. Manajemen Spare Part

- Inventaris spare part dengan stok
- Harga beli dan harga jual
- Pencatatan pembelian spare part
- Riwayat pembelian

### 4. Work Order

- Pembuatan work order baru
- Pemilihan pelanggan dan spare part
- Status work order (pending, dikerjakan, selesai, dibayar)
- Detail work order lengkap
- **Generasi nota PDF**
- **Bagikan nota via WhatsApp, Email, dll**

### 5. Laporan Keuangan

- **Dashboard dengan statistik real-time**
- **Filter periode:** Hari Ini, Minggu Ini, Bulan Ini, Tahun Ini
- **Riwayat pendapatan dengan kategori:**
  - **Harian**: Data 30 hari terakhir (hari ini disorot)
  - **Mingguan**: Data 12 minggu terakhir
  - **Bulanan**: Data 12 bulan terakhir
  - **Tahunan**: Data 5 tahun terakhir
- Rincian breakdown (work orders, spare part sales, total customers)

## Teknologi yang Digunakan

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: Provider
- **PDF Generation**: pdf package
- **Printing**: printing package
- **Sharing**: share_plus package
- **Charts**: fl_chart
- **Date Formatting**: intl

## Struktur Proyek

```
lib/
├── models/           # Model data
├── providers/        # State management
├── screens/          # Halaman aplikasi
├── services/         # Layanan API dan Firebase
└── main.dart         # Entry point aplikasi
```

## Cara Menjalankan

1. Clone repository ini
2. Install dependencies: `flutter pub get`
3. Konfigurasi Firebase (tambahkan file konfigurasi)
4. Jalankan aplikasi: `flutter run`

## Fitur Laporan Keuangan Terbaru

### Filter Periode

Aplikasi sekarang memiliki 4 filter periode untuk melihat total pendapatan:

- **Hari Ini**: Pendapatan hari ini
- **Minggu Ini**: Pendapatan minggu ini (Senin-Minggu)
- **Bulan Ini**: Pendapatan bulan ini
- **Tahun Ini**: Pendapatan tahun ini

### Riwayat Pendapatan

Aplikasi memiliki fitur riwayat pendapatan yang komprehensif:

- **Tampilan Harian**: Melihat pendapatan per hari untuk 30 hari terakhir
  - **Hari ini disorot** dengan warna biru dan badge "HARI INI"
- **Tampilan Mingguan**: Melihat pendapatan per minggu untuk 12 minggu terakhir
- **Tampilan Bulanan**: Melihat pendapatan per bulan untuk 12 bulan terakhir
- **Tampilan Tahunan**: Melihat pendapatan per tahun untuk 5 tahun terakhir

### Cara Menggunakan

1. Buka menu "Laporan Keuangan"
2. Pilih periode di bagian atas (Hari Ini/Minggu Ini/Bulan Ini/Tahun Ini)
3. Scroll ke bagian "Riwayat Pendapatan"
4. Pilih kategori yang diinginkan (Harian/Mingguan/Bulanan/Tahunan)
5. Data akan otomatis diperbarui sesuai periode yang dipilih
6. Hari ini akan otomatis disorot dengan warna biru di tampilan harian

### Sumber Data

Pendapatan dihitung dari:

- Work Order dengan status "dibayar"
- Penjualan spare part
- Total jasa dan spare part dalam setiap transaksi

## Kontribusi

Silakan berkontribusi dengan membuat pull request atau melaporkan bug melalui issues.

## Lisensi

Proyek ini dilisensikan di bawah MIT License.
