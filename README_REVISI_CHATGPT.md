# Ringkasan Revisi JogjaSplorasi

Revisi ini disusun dari pembahasan UI/fitur terakhir.

## Profil
- Halaman Profil disederhanakan agar fokus pada akun.
- Menu yang tersisa: Edit Profil, Favorit Saya, Keluar Akun.
- Menu Tools TPM, Converter, Sensor, Mini Game, dan Saran & Kesan tidak lagi ditampilkan ulang di Profil.

## Beranda
- Menu Utama dipindah ke posisi atas agar lebih terlihat.
- Card Menu Utama diperbesar dengan ikon lebih besar.
- Section Kategori Wisata di Beranda dihapus karena filter kategori sudah tersedia di Jelajahi.
- Banner cuaca sekarang menampilkan lokasi lebih spesifik secara heuristik: kecamatan/kabupaten/provinsi DI Yogyakarta.
- UV index diperbaiki agar memakai jam saat ini, bukan data UV jam pertama. Jika API mengembalikan 0 saat siang, aplikasi memberi estimasi minimal.

## Jelajahi
- Filter bagian atas dibuat lebih sederhana dan menyatu dalam panel kontrol.
- Kategori tidak lagi ditampilkan sebagai banyak chip horizontal.
- Data destinasi dibatasi 20 item per halaman.
- Ditambahkan navigasi Sebelumnya / Berikutnya.

## Favorit
- Backend destinasi sekarang bisa menambahkan flag `isFavorite` ketika request membawa token user.
- Endpoint favorit backend tetap memakai `/me/favorites` untuk tambah, hapus, dan ambil daftar favorit.
- Frontend tetap menyimpan favorit lokal dan sinkron ke backend.

## AI Guide
- Backend AI Guide kini mendukung Google Gemini.
- Gunakan konfigurasi berikut di backend `.env`:

```env
AI_GUIDE_MODE=gemini
GEMINI_API_KEY=ISI_API_KEY_GEMINI_ANDA
GEMINI_MODEL=gemini-1.5-flash
```

- Prompt AI diarahkan menjadi pemandu wisata Jogja yang sopan, informatif, bernuansa Jawa, dan tetap berbasis data database.
- Jika Gemini gagal atau API key kosong, sistem tetap fallback ke engine lokal berbasis database.

## Catatan Testing
Jalankan setelah ekstrak:

```bash
flutter pub get
flutter analyze
flutter run
```

Backend:

```bash
cd backend
npm install
npx prisma@5.22.0 generate
npx prisma@5.22.0 db push
npm run db:seed
npm run dev
```
