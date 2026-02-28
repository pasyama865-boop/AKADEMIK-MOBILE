Anda berperan sebagai **Senior Software Architect, Technical Auditor, dan Product Strategist** dengan pengalaman 15+ tahun dalam membangun sistem akademik skala universitas.

Lakukan audit menyeluruh terhadap project **SISTEM AKADEMIK MOBILE**, yaitu aplikasi informasi akademik berbasis mobile yang memiliki tiga role utama: Admin, Dosen, dan Mahasiswa.

Audit dilakukan secara profesional, objektif, dan berbasis standar sistem produksi.
# 🎯 KONTEKS SISTEM
Sistem menggunakan arsitektur modern berbasis mobile + backend API + database terpusat.
# 🧩 BAGIAN 1 — ANALISIS ARSITEKTUR SISTEM
Evaluasi:
1. Kesesuaian arsitektur dengan kebutuhan sistem akademik.
2. Apakah pemisahan frontend, backend, dan database sudah tepat.
3. Apakah struktur mendukung skalabilitas ribuan mahasiswa.
4. Apakah sistem siap untuk multi-semester dan multi-angkatan.
5. Potensi technical debt jangka panjang.
Berikan:
* Kelebihan arsitektur saat ini
* Kekurangan arsitektur
* Risiko jangka panjang
* Rekomendasi peningkatan arsitektur
# 🗂 BAGIAN 2 — ANALISIS LOGIKA BISNIS AKADEMIK
Audit secara kritis:
1. Apakah alur semester sudah realistis.
2. Validasi KRS (batas SKS, bentrok jadwal, periode KRS).
3. Validasi input nilai (hanya dosen pengampu).
4. Penguncian semester dan dampaknya.
5. Konsistensi perhitungan IP dan IPK.
6. Penanganan mahasiswa cuti / tidak aktif.
7. Potensi konflik data antar role.
Berikan:
* Kelebihan logika sistem
* Kekurangan atau celah logika
* Potensi bug tersembunyi
* Saran perbaikan logika
# 🗄 BAGIAN 3 — ANALISIS DATABASE & DATA INTEGRITY
Evaluasi:
1. Struktur tabel utama.
2. Relasi antar entitas.
3. Normalisasi data.
4. Risiko redundansi.
5. Indexing strategy.
6. Potensi bottleneck performa saat data besar.
7. Konsistensi foreign key.
8. Risiko data race condition.
Berikan:
* Kelebihan desain database
* Kekurangan desain database
* Rekomendasi optimasi
* Risiko scaling
# 🔐 BAGIAN 4 — ANALISIS KEAMANAN SISTEM
Audit secara mendalam:
1. Authentication (JWT / token handling).
2. Authorization (role-based access).
3. Validasi input.
4. Password hashing.
5. Token expiration.
6. Rate limiting.
7. SQL injection risk.
8. XSS risk.
9. CSRF handling.
10. Environment variable security.
11. Logging dan audit trail.
Berikan:
* Potensi celah keamanan
* Tingkat risiko (Low / Medium / High)
* Rekomendasi mitigasi detail
# ⚙ BAGIAN 5 — ANALISIS PERFORMA & SKALABILITAS
Evaluasi:
1. Kinerja saat ribuan mahasiswa akses bersamaan.
2. Optimasi query database.
3. Penggunaan caching.
4. Struktur response API.
5. Latency mobile-to-server.
6. Kemampuan scaling horizontal.
Berikan:
* Potensi bottleneck
* Risiko overload
* Saran optimasi performa
* Saran arsitektur scaling
# 📱 BAGIAN 6 — ANALISIS USER EXPERIENCE (UX)
Evaluasi:
1. Kemudahan penggunaan tiap role.
2. Kejelasan navigasi.
3. Feedback error.
4. Loading state.
5. Responsiveness.
6. Aksesibilitas.
7. Konsistensi desain.
Berikan:
* Kekurangan UX
* Rekomendasi perbaikan
* Quick improvements
# 🧪 BAGIAN 7 — ANALISIS TESTING & QUALITY ASSURANCE
Evaluasi:
1. Unit testing.
2. Integration testing.
3. API testing.
4. Manual testing scenario.
5. Edge case testing.
6. Monitoring error produksi.
Berikan:
* Area yang belum tercover
* Risiko produksi
* Rekomendasi peningkatan QA
# 📊 BAGIAN 8 — RINGKASAN GLOBAL
Buat tabel ringkasan:
| Aspek | Kelebihan | Kekurangan | Risiko | Prioritas |
| ----- | --------- | ---------- | ------ | --------- |


# 💡 BAGIAN 9 — SARAN PENAMBAHAN FITUR
Berikan saran fitur tambahan yang relevan untuk sistem akademik modern, dikelompokkan menjadi:
### 🔴 Prioritas Tinggi
### 🟡 Prioritas Menengah
### 🟢 Inovasi Jangka Panjang
Contoh kategori fitur:
* Notifikasi real-time
* Statistik akademik
* Monitoring kehadiran
* Sistem peringatan IP rendah
* Approval KRS oleh dosen wali
* Sistem transkrip otomatis
* Integrasi pembayaran UKT
* Export PDF nilai
* Audit log admin
* Multi-kampus support
Jelaskan alasan strategis setiap fitur.

# 🧠 BAGIAN 10 — ROADMAP PERBAIKAN
Kelompokkan rekomendasi menjadi:
### 🔴 Critical (Perlu diperbaiki segera)
### 🟡 Important (Direncanakan dalam 3–6 bulan)
### 🟢 Enhancement (Pengembangan lanjutan)

# 📌 FORMAT OUTPUT WAJIB

Jawaban harus:

* Sangat sistematis
* Tidak umum
* Tidak generik
* Detail dan analitis
* Production-ready mindset
* Berpikir sebagai auditor profesional

