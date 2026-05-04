# Revisi Prioritas A - JogjaSplorasi

Revisi ini fokus pada bug/UX yang paling terlihat saat demo:

1. **Beranda disusun ulang**
   - Urutan sekarang: Header -> Search -> Cuaca -> Menu Utama -> Destinasi Unggulan -> Terdekat.
   - Menu Utama diurutkan: Guide AI, Kuis Budaya, Konversi Kurs, Konversi Waktu.

2. **Overflow Menu Utama diperbaiki**
   - Card menu utama diberi tinggi/padding/font yang lebih aman agar tidak muncul garis overflow merah.

3. **Favorite dibuat lebih responsif**
   - Toggle favorite sekarang tetap mengubah state lokal walaupun backend sedang lambat/gagal.
   - Aksi favorite yang gagal sync disimpan sebagai pending action dan dicoba lagi saat sync berikutnya.
   - Data destinasi dari backend sekarang dikembalikan ke UI setelah digabung dengan favorite lokal, sehingga ikon heart tidak hilang lagi setelah refresh.
   - Warna favorite aktif dibuat pink/merah agar jelas terlihat.

4. **Halaman Favorit dan counter Profil lebih aman**
   - Fetch favorite dari backend tidak lagi menghapus favorite lokal secara agresif.
   - Favorite lokal tetap menjadi fallback agar item yang sudah di-love muncul di Favorit Saya.

5. **Pagination Jelajahi dirapikan**
   - Tombol Sebelumnya/Berikutnya diperbesar dan teksnya dibuat lebih proporsional.

6. **UV weather polish ringan**
   - Tampilan UV 0 saat malam diubah menjadi label `Malam`.
   - Jika siang tetapi nilai API kosong/0, tampilan fallback menjadi `1.0 Rendah`.

## Cara pakai

Ekstrak ZIP ini lalu timpa isi folder proyek Anda. Setelah itu jalankan:

```bat
flutter pub get
flutter analyze
flutter run
```

Backend:

```bat
cd backend
npm install
npx prisma@5.22.0 generate
npx prisma@5.22.0 db push
npm run db:seed
npm run dev
```
