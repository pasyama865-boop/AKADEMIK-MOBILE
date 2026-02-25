<?php

namespace Database\Seeders;


use App\Models\MataKuliah;
use App\Models\Ruangan;
use App\Models\Semester;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DataMasterSeeder extends Seeder
{
    public function run(): void
    { // Buat semester aktif
        Semester::create([
            'nama' => 'Ganjil 2023/2024',
            'tanggal_mulai' => '2023-09-01',
            'tanggal_selesai' => '2024-01-31',
            'is_active' => true
        ]);
        // Buat ruangan
        Ruangan::create([
            'nama' => 'Lab komputer 1',
            'gedung' => 'Gedung A',
            'kapasitas' => 40
        ]);
        Ruangan::create([
            'nama' => 'Kelas Teori 101',
            'gedung' => 'Gedung B',
            'kapasitas' => 60
        ]);
        // Buat mata kuliah
        MataKuliah::create([
            'kode_matkul' => 'IF101',
            'nama_matkul' => 'Algoritma dan Pemrograman',
            'sks' => 4,
            'semester_paket' => 1
        ]);
        MataKuliah::create([
            'kode_matkul' => 'IF102',
            'nama_matkul' => 'Basis data dasar',
            'sks' => 3,
            'semester_paket' => 2
        ]);
        MataKuliah::create([
            'kode_matkul' => 'SI201',
            'nama_matkul' => 'Analisis Proses Bisnis',
            'sks' => 2,
            'semester_paket' => 3
        ]);
    }
}
