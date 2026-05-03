# Patch Quiz Budaya JogjaSplorasi - 100 Soal Baru

Patch ini mengganti seluruh seed soal quiz lama dengan **100 soal baru** bertema:

- sejarah Yogyakarta,
- budaya dan tradisi Jawa/Yogyakarta,
- destinasi ikonik,
- kuliner Jogja,
- filosofi dan simbol Jogja,
- etika wisata,
- fakta seru dan fitur aplikasi.

## Cara pakai

1. Extract ZIP ini ke root folder proyek JogjaSplorasi.
2. Pilih replace/overwrite untuk file yang sama.
3. Jalankan ulang seed database backend:

```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run db:seed
```

Atau kalau backend sudah biasa dijalankan lewat script proyek Anda, cukup pastikan perintah seed dijalankan ulang.

## File yang berubah

- `backend/prisma/seed.js`

## Catatan

Patch ini hanya fokus mengganti data quiz. Struktur tabel, route API, dan UI quiz tidak diubah.
