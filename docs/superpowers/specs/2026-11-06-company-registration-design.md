# Pendaftaran Perusahaan

## Tujuan

Perusahaan baru dapat membuat akun supervisor umum dari alur onboarding. Form mengikuti gaya visual APK Tracker dan mengirim identitas perusahaan, akun supervisor, serta logo ke backend yang dipilih melalui `LOCAL_SERVER`.

## Ruang lingkup

- Ganti form register saat ini dengan form pendaftaran perusahaan.
- Bagi form menjadi dua langkah dengan indikator progres dan transisi animasi: identitas perusahaan/logo, lalu akun supervisor. Tombol kembali mempertahankan data yang sudah dimasukkan.
- Data form: nama perusahaan, email perusahaan, telepon, alamat, nama penanggung jawab, username supervisor, password, konfirmasi password, dan logo.
- Validasi input wajib, format email, kecocokan password, dan gambar logo yang dipilih.
- Gunakan endpoint yang dipilih pengguna: `POST ${Env.baseUrl}/api/register`, dengan `multipart/form-data`.
- Payload memakai `username`, `email`, `password`, `password_confirmation`, `role=supervisor_umum`, `company_name`, `company_phone`, `company_address`, `contact_name`, dan file `logo`.
- Setelah respons `201`, tampilkan pesan sukses dan arahkan ke Login seperti alur sekarang.
- Tambahkan tautan ke Register pada Login dan tautan ke Login pada Register. Tombol Register onboarding tetap memakai route `/register` yang sudah ada.

## Batas dan asumsi integrasi

Project ini hanya berisi aplikasi Flutter, bukan kode backend. Karena itu server harus menerima multipart pada endpoint `/api/register`, menyimpan logo dan profil perusahaan, serta membatasi role yang dapat dibuat publik ke `supervisor_umum`. Backend tetap harus melakukan validasi dan tidak mempercayai role atau input lain dari client. Format error `422` dan pesan sukses `201` mengikuti pola yang sudah dipakai halaman register.

`LOCAL_SERVER` tetap menjadi satu-satunya base URL yang dipakai otomatis. Tidak ada perubahan pada `.env` atau pemilihan environment.

## Pilihan pendekatan

- **Menambah data perusahaan ke endpoint `/api/register` (dipilih pengguna):** mempertahankan URL yang sudah dipakai aplikasi; backend perlu memperluas kontrak request menjadi multipart.
- **Endpoint khusus perusahaan:** memberi batas kontrak yang lebih jelas dan memisahkan akun perusahaan dari register lama, tetapi pengguna memilih untuk memakai endpoint yang ada.

## Bukan tujuan

- Mengubah kode atau skema backend.
- Mengubah login, session storage, onboarding, atau navigasi setelah pendaftaran berhasil.
- Mengubah endpoint base URL atau mengirim kredensial rahasia melalui `.env`.
