# Patch JogjaSplorasi

Isi ZIP ini dibuat sebagai **overlay patch**. Salin/ekstrak isinya ke root proyek lama, lalu pilih replace/overwrite.

## Perubahan utama

- Konsistensi branding menjadi **JogjaSplorasi**.
- Palet warna diubah ke nuansa Jogja: emas keraton, coklat hangat, krem, dan aksen hijau.
- Copywriting login/register dibuat lebih ramah dan bernuansa tour guide.
- Tambahan reusable `JogjaPageHeader` dengan tombol back kiri atas untuk halaman turunan.
- Label tombol filter/sort di Explore dibuat lebih mudah dipahami: `Terdekat`, `Grid/List`, `Filter`.
- Filter sheet dibuat lebih jelas untuk pengguna semua umur.
- Bottom navigation memakai label `Guide AI`.
- Profil diberi wording keamanan yang lebih jelas dan placeholder menu tema Light/Dark.
- Konfigurasi backend lokal disamakan ke PostgreSQL Docker: `localhost:5432`, password `postgres`, API port `3000`.
- README backend diperbarui dari port `4000` ke `3000`.

## Setelah overwrite

Jalankan:

```bash
flutter clean
flutter pub get
```

Backend lokal:

```bash
docker compose up --build
```

Untuk HP fisik, jalankan Flutter dengan IP laptop:

```bash
flutter run --dart-define=LOCAL_SERVER_IP=192.168.x.x --dart-define=BACKEND_PORT=3000
```

## Catatan

Saya tidak menemukan file `icon.png` di ZIP yang diterima. Yang ada adalah app icon bawaan di Android/iOS/Web. Jika Anda punya logo final `icon.png`, letakkan di `assets/images/icons/icon.png`, lalu kita bisa sambungkan ke splash/login/app icon.
