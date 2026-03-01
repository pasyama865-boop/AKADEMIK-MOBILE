Tolong sesuaikan dengan data yang sudah ada. 
jangan sampai ada 2 kegunaan yang sama di setiap halaman dashboard admin, dosen, dan mahasiswa.
Buatkan desain UI/UX lengkap untuk aplikasi **Sistem Akademik Mobile** skala universitas dengan tiga role utama:

* Admin
* Dosen
* Mahasiswa

Desain harus modern, clean, minimalis, scalable, dan mendukung **Light Mode & Dark Mode native (bukan sekadar invert warna)**.

Gunakan pendekatan design system terstruktur, berbasis mobile-first.

---

# 🎯 1. TUJUAN PRODUK

Aplikasi ini adalah sistem informasi akademik berbasis mobile yang memungkinkan:

* Mahasiswa mengakses data akademik dan mengisi KRS
* Dosen mengelola kelas dan nilai
* Admin mengelola sistem akademik

Target pengguna: ribuan mahasiswa aktif.

Fokus utama:

* Efisiensi interaksi
* Kejelasan informasi
* Validasi akademik yang kuat
* Konsistensi UI
* Performa ringan

---

# 📱 2. PLATFORM

* Mobile application (Android & iOS)
* Responsive untuk berbagai ukuran layar
* Menggunakan bottom navigation untuk Mahasiswa & Dosen
* Menggunakan tab/drawer untuk Admin

---

# 🎨 3. DESIGN STYLE YANG DIINGINKAN

Desain harus:

* Modern SaaS style
* Clean layout
* Card-based UI
* Soft shadow (light mode)
* Subtle border (dark mode)
* Rounded corner 12–16px
* Menggunakan 8pt spacing system
* Typography hierarchy jelas

Inspirasi visual:

* Modern fintech apps
* Productivity apps
* SaaS dashboard minimal

---

# 🌙 4. DARK MODE REQUIREMENT

Dark mode harus:

* Menggunakan tone dark slate (bukan hitam pekat)
* Memiliki surface layering
* Menghindari pure white text
* Memenuhi WCAG AA contrast
* Menggunakan design token untuk switching theme

Pastikan:

* Badge warna tetap kontras
* Chart tetap terbaca
* Status tetap jelas

---

# 🎨 5. DESIGN SYSTEM REQUIREMENT

Buatkan:

## A. Color System

* Primary
* Secondary
* Success
* Warning
* Danger
* Background
* Surface
* Text primary
* Text secondary
* Border

Versi Light dan Dark.

---

## B. Typography

* Font modern (Inter / SF Pro / Roboto)
* Heading scale (H1–H4)
* Body
* Caption
* Data number emphasis

---

## C. Spacing

Gunakan 8pt grid system.

---

## D. Component Library

Harus memiliki:

* Button (primary, secondary, ghost, disabled)
* Card
* Badge status (success, pending, rejected)
* Modal confirmation
* Snackbar / toast
* Skeleton loader
* Empty state illustration
* Dropdown semester selector
* Segmented control
* Bottom navigation
* Tab navigation
* Form input
* Checkbox
* Toggle switch (untuk dark mode)

---

# 👨‍🎓 6. ROLE: MAHASISWA

Buat halaman berikut:

## 1. Login

* Simple form
* Error feedback jelas
* Loading state

## 2. Dashboard

Menampilkan:

* Greeting + foto
* IPK
* Total SKS lulus
* Status akademik
* Semester aktif
* Jadwal terdekat
* Quick action button:

  * Isi KRS
  * Lihat Nilai
  * Jadwal

Gunakan card-based layout.

---

## 3. Halaman KRS

Fitur:

* Pilih semester
* List mata kuliah dengan checkbox
* Counter SKS real-time
* Validasi bentrok jadwal
* Status approval dosen wali
* Tombol submit disable jika invalid

Tampilkan konflik dalam modal detail.

---

## 4. Jadwal

* Tampilan list atau calendar
* Filter semester
* Warna beda tiap mata kuliah

---

## 5. Nilai

* Tampilkan nilai per semester
* Hitung IP semester
* Hitung IPK kumulatif
* Status nilai (draft / final)

---

## 6. Profil

* Data pribadi
* Status akademik
* Ganti password
* Toggle dark mode

---

# 👨‍🏫 7. ROLE: DOSEN

Halaman:

## 1. Dashboard

* Total kelas
* Total mahasiswa
* Quick action:

  * Input nilai
  * Approval KRS
  * Presensi

---

## 2. Input Nilai

* List mahasiswa
* Inline editable grade
* Mode draft
* Publish final
* Lock setelah semester ditutup

---

## 3. Approval KRS

* List mahasiswa
* Detail KRS
* Approve / Reject
* Catatan revisi

---

## 4. Jadwal Mengajar

---

# 👨‍💼 8. ROLE: ADMIN

Halaman:

## 1. Dashboard

* Total mahasiswa
* Total dosen
* Semester aktif
* Statistik IP
* Log aktivitas

---

## 2. Master Data

* Mahasiswa
* Dosen
* Mata kuliah
* Prodi
* Semester

---

## 3. Monitoring Akademik

* Mahasiswa IP rendah
* Mahasiswa cuti
* Statistik kelulusan

---

## 4. Pengaturan Sistem

* Buka/tutup KRS
* Kunci semester
* Manajemen role

---

# ⚙ 9. INTERACTION & STATE MANAGEMENT

Setiap halaman harus memiliki:

* Loading state (skeleton)
* Empty state
* Error state
* Success feedback
* Pull to refresh
* Offline state indicator

---

# ♿ 10. AKSESIBILITAS

* Tap area minimal 44px
* High contrast mode
* Screen reader label
* Dynamic font scaling

---

# 📊 11. DATA VISUALIZATION

Gunakan:

* Bar chart
* Line chart
* Progress ring
* Statistik IP

Pastikan chart readable di dark mode.

---

# 🧠 12. UX PRINCIPLES WAJIB

* Jangan lebih dari 2 level navigasi
* Hindari clutter
* Prioritaskan data penting
* Gunakan progressive disclosure
* Semua validasi real-time

---

# 🧩 13. OUTPUT YANG DIHARAPKAN

Hasil desain harus mencakup:

1. Wireframe lengkap tiap halaman
2. Mockup high fidelity (light & dark)
3. Design system lengkap
4. Component library
5. Interaction flow
6. User journey map
7. State design (loading, error, empty)
8. Responsive adaptation

---

# 🔥 14. KUALITAS DESAIN YANG DIHARAPKAN

Desain harus:

* Production-ready
* Konsisten
* Scalable
* Siap untuk ribuan user
* Tidak generik
* Tidak berlebihan
* Berbasis praktik UX modern

---

Jika diperlukan, tambahkan:

* Micro interaction
* Subtle animation
* Haptic feedback
* Real-time notification badge

---

# 🚀 PENUTUP PROMPT

Desain harus mencerminkan sistem akademik profesional skala universitas modern dengan standar SaaS enterprise.

Prioritaskan:

* Kejelasan informasi
* Validasi akademik
* Keamanan UX
* Skalabilitas fitur
* Konsistensi design system
* Dark mode native yang matang
