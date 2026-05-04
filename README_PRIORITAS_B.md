# Revisi Prioritas B - AI Guide Gemini

Revisi ini fokus pada kualitas AI Guide agar lebih layak dijadikan fitur unggulan JogjaSplorasi.

## Perubahan utama

1. Prompt Gemini diperkuat agar AI berperan sebagai **Mas/Mbak Guide Jogja**.
2. Bahasa utama tetap Indonesia, tetapi diberi nuansa Jawa ringan seperti:
   - Sugeng rawuh
   - Nggih
   - Monggo
   - Panjenengan
   - Matur nuwun
3. AI diwajibkan memakai data destinasi dari database, tidak mengarang destinasi, harga, jam buka, alamat, atau fasilitas.
4. Jika Gemini gagal, backend sekarang menulis log yang lebih jelas dan fallback ke local guide engine.
5. Guardrail response sekarang membedakan mode:
   - `gemini-database-grounded`
   - `openrouter-database-grounded`
   - `database-grounded-local`
6. Fallback local guide engine juga diperbaiki agar tetap bernuansa Jogja dan tidak lagi memakai template umum seperti “Siap, ...”.
7. Rekomendasi malam, kuliner, budaya, dan alam diberi scoring yang lebih baik sebelum konteks dikirim ke Gemini.

## File yang diubah

- `backend/src/utils/llmProvider.js`
- `backend/src/utils/aiGuideEngine.js`
- `backend/src/routes/ai.routes.js`
- `backend/.env.example`

## Konfigurasi .env lokal

Isi file `backend/.env` Anda seperti ini untuk Gemini:

```env
AI_GUIDE_MODE=gemini
GEMINI_API_KEY=ISI_API_KEY_GEMINI_ANDA
GEMINI_MODEL=gemini-1.5-flash
AI_GUIDE_MAX_CONTEXT_DESTINATIONS=8
LOG_LEVEL=debug
```

Jangan masukkan API key ke Flutter. API key cukup berada di backend.

## Cara memastikan Gemini aktif

1. Restart backend setelah mengubah `.env`:

```bash
npm run dev
```

2. Kirim pertanyaan di Guide AI, misalnya:

```txt
saran tempat yang bisa dikunjungi malam ini?
```

3. Cek log backend. Jika Gemini aktif, harus muncul log seperti:

```txt
[AI] buildLlmReply invoked
[AI] Gemini response generated
```

Jika Gemini gagal, log akan menampilkan:

```txt
[AI] Gemini failed, using local fallback
```

Dalam kondisi fallback, aplikasi tetap menjawab, tetapi jawabannya berasal dari local guide engine.

## Catatan keamanan

Jika API key pernah ditempel ke chat atau repository, sebaiknya revoke key lama di Google AI Studio lalu buat key baru.
