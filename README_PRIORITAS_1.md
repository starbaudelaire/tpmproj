# Revisi Prioritas 1 - JogjaSplorasi

Perubahan yang diterapkan:

1. Profil menampilkan kembali menu **Kunci Aplikasi Biometrik** di section Keamanan.
2. Wording biometric diganti dari "login biometrik" menjadi "buka/kunci aplikasi biometrik" agar sesuai konsep unlock session.
3. Merge status `isFavorite` dari backend ke cache lokal diperbaiki agar data remote tidak tertimpa cache lama.
4. Mode list Jelajahi sekarang punya tombol favorit/heart.
5. `.env.example` disiapkan untuk demo Gemini (`AI_GUIDE_MODE=gemini`). Isi `GEMINI_API_KEY` sendiri sebelum menjalankan backend.
6. ZIP final dibersihkan dari `build/`, `.dart_tool/`, `node_modules/`, dan `backend/.env`.

Cara mengaktifkan Gemini saat demo:

```env
AI_GUIDE_MODE=gemini
GEMINI_API_KEY=ISI_API_KEY_GEMINI_ANDA
GEMINI_MODEL=gemini-1.5-flash
```

Jangan upload file `.env` asli ke ZIP pengumpulan. Gunakan `.env.example` sebagai template.
