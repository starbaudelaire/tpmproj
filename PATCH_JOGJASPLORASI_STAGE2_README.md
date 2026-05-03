# Patch Tahap 2 JogjaSplorasi

Patch ini dibuat sebagai overlay/overwrite ke root proyek JogjaSplorasi.

## Isi perubahan utama

1. **Guide AI lebih kuat untuk requirement LLM**
   - Menambah optional provider OpenRouter via `AI_GUIDE_MODE=openrouter`.
   - Jika API key kosong, backend otomatis fallback ke engine lokal berbasis database.
   - Jawaban AI tetap dibatasi data destinasi agar tidak mengarang tempat.
   - Jawaban kini menyertakan link Google Maps destinasi.

2. **Global Search**
   - Route baru: `/global-search`.
   - Bisa mencari destinasi dan fitur aplikasi: Guide AI, Mini Game, Converter, Sensor, Profil/Tema, Saran & Kesan TPM.
   - Ada kartu “Tanya Guide AI tentang pencarian ini”.

3. **Profil + tema**
   - Tambah shortcut “Cari Semua”.
   - Toggle Light/Dark tersimpan di SharedPreferences.
   - `CupertinoApp` sudah membaca controller tema.

4. **Quick Guide Home**
   - Shortcut Home diperluas: Global Search, Kurs, Waktu, Sensor, Guide AI, Kuis.

5. **Sensor Hub**
   - Tambah panel “Shake to Discover”.
   - Tombol “Coba” sebagai fallback demo di web/emulator.
   - Tetap mempertahankan accelerometer dan gyroscope live visualizer.

6. **Quiz Budaya Jogja**
   - Seed quiz diubah menjadi pertanyaan budaya/sejarah/etika/kuliner Jogja yang lebih menarik.
   - Pertanyaan tidak lagi sekadar tebak kategori destinasi.

## Cara pakai

1. Extract isi ZIP ini ke root proyek lama.
2. Pilih replace/overwrite semua file yang sama.
3. Jalankan ulang dependency:

```bash
flutter clean
flutter pub get
```

4. Jalankan backend:

```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run db:seed
npm run dev
```

5. Untuk memakai LLM OpenRouter, isi `backend/.env`:

```env
AI_GUIDE_MODE=openrouter
OPENROUTER_API_KEY=isi_api_key_anda
OPENROUTER_MODEL=openai/gpt-4o-mini
```

Jika tidak punya API key, biarkan `AI_GUIDE_MODE=local`; fitur AI tetap bisa demo dengan fallback lokal.

## Catatan

Saya belum bisa menjalankan `flutter analyze`/build APK di environment ini karena Flutter CLI tidak tersedia. Jika setelah overwrite ada error compile, kirim log error pertama agar bisa dipatch cepat.
