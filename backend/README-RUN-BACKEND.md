# JogjaSplorasi Backend Real PostgreSQL Setup

Patch ini membuat backend memakai database asli PostgreSQL, bukan mock dan bukan hardcoded auth.

## Syarat

1. Docker Desktop sudah terinstall dan sedang running.
2. Node.js sudah terinstall.
3. Jalankan perintah dari folder `backend`.

## Cara jalan cepat

```bat
cd backend
npm install
npm run setup
npm run dev
```

`npm run setup` akan melakukan ini otomatis:

1. Membuat `backend/.env` jika belum ada.
2. Menjalankan PostgreSQL asli via Docker Compose.
3. Menunggu PostgreSQL siap di `localhost:5432`.
4. Menjalankan `prisma generate`.
5. Menjalankan `prisma db push` agar tabel asli dibuat di PostgreSQL.
6. Menjalankan seed destinasi dan quiz awal ke database.

## Cek backend

Buka browser:

```txt
http://localhost:3000/health
http://localhost:3000/health/ready
```

Kalau `/health/ready` menampilkan `status: ready`, backend dan database sudah siap.

## Jalankan Flutter Web

Di terminal lain, dari folder root proyek:

```bat
flutter run -d chrome
```

Aplikasi Flutter harus mengarah ke:

```txt
http://localhost:3000/api
```

## Register dan login

Register/login akan masuk ke tabel `User` di PostgreSQL. Password di-hash dengan bcrypt. Token dibuat dengan JWT.

## Akun admin seed

Seed membuat akun admin awal:

```txt
Email: admin@jogjasplorasi.local
Password: Admin12345
```

Akun ini hanya akun awal untuk keperluan admin/demo. User baru tetap dibuat lewat register dan tersimpan di PostgreSQL.

## Jika error port 5432

Cek apakah port dipakai service lain:

```bat
netstat -ano | findstr :5432
```

Jika ada PostgreSQL lokal lain, hentikan service itu atau ubah port mapping di `docker-compose.yml`.
