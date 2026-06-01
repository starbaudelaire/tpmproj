@echo off
echo Membersihkan cache dan file build lama JogjaSplorasi...

if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
if exist android\build rmdir /s /q android\build
if exist android\.gradle rmdir /s /q android\.gradle
if exist backend\node_modules echo Lewati backend\node_modules agar npm install ulang tidak wajib.

if exist backend\prisma\quiz_questions.js del /q backend\prisma\quiz_questions.js
if exist backend\scripts\enrich-destination-descriptions.js del /q backend\scripts\enrich-destination-descriptions.js

echo Selesai. Jalankan flutter pub get dan run-backend.bat bila diperlukan.
