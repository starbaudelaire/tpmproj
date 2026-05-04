# Revisi Prioritas C - UI Polish dan Normalisasi Data

Perubahan pada tahap ini berfokus pada polishing visual dan data display:

1. Login screen
   - Headline login diganti menjadi `Sugeng rawuh`.
   - Label tab login diganti menjadi `Masuk`.
   - Subtitle dibuat lebih hangat dan sesuai konsep wisata Jogja.

2. Normalisasi tag/kategori destinasi
   - Tampilan kategori sekarang memakai helper `DestinationDisplayUtil`.
   - Data mentah seperti `masakan jawa`, `bakmi jawa`, `viewpoint`, dan sejenisnya tidak lagi tampil mentah di card utama.
   - Kuliner ditampilkan sebagai `Kuliner`, destinasi sejarah sebagai `Sejarah`, museum/budaya sebagai `Budaya`, dan kategori lain diawali huruf kapital.
   - Jam buka yang terlalu teknis seperti `Perlu verifikasi berkala...` diringkas menjadi `Perlu verifikasi`.

3. Spacing responsif
   - Padding horizontal halaman utama dinaikkan dari 20 px ke 24 px di beberapa screen utama agar konten tidak terlalu menempel pada sisi layar.
   - Diterapkan pada Home, Explore, Guide AI, Profile, Favorites, Converter, Feedback, TPM, Sensor Hub, dan Mini Game.

4. Cuaca / UV
   - Tampilan UV tetap dipoles agar malam hari tampil lebih natural sebagai `Malam`, sedangkan siang hari tetap memakai fallback minimal `1.0 Rendah` jika API memberikan nilai kosong atau nol.

File utama yang berubah:
- lib/features/auth/presentation/auth_screen.dart
- lib/core/utils/destination_display_util.dart
- lib/shared/widgets/destination_card_large.dart
- lib/shared/widgets/destination_card_compact.dart
- lib/features/explore/presentation/widgets/destination_list.dart
- lib/features/home/presentation/widgets/nearby_destinations_row.dart
- lib/features/destination_detail/presentation/destination_detail_screen.dart
- lib/features/destination_detail/presentation/widgets/info_strip.dart
- lib/features/destination_detail/presentation/widgets/similar_destinations.dart
- lib/features/global_search/presentation/global_search_screen.dart
