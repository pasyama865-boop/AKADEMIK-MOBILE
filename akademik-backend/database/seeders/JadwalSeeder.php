<?php

namespace Database\Seeders;

use App\Models\Jadwal;
use App\Models\MataKuliah;
use App\Models\Ruangan;
use App\Models\Semester;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class JadwalSeeder extends Seeder
{
    public function run(): void
    {// kita butuh dosen, dek dulu, kalau belum ada, buat baru
        $dosen = User::firstOrCreate(
            ['email' => 'dosen@kampus.ac.id'],
            ['name' => 'Dr. Budi Santoso, M.Kom',
            'password' => bcrypt('budi123'),
            'role' => 'dosen',
            'nim_nip' => 'DOS001'
            ]
            );
    // Ambil data master pertama yang di temukan di database
        $matkul = MataKuliah::where('kode_matkul', 'IF101')->first();
        $ruangan = Ruangan::first();
        $semester = Semester::where('is_active', true)->first();

    // Pastikan data master ada
        if (!$matkul || !$ruangan || !$semester) {
            $this->command->error('Data master matkul,ruangan,semester belum ada! Jalankan datamasterseeder dulu.');
            return;
        }
    // Buat jadwal
        Jadwal::create([
            'mata_kuliah_id' => $matkul->id,
            'dosen_id' => $dosen->id,
            'ruangan_id' => $ruangan->id,
            'semester_id' => $semester->id,
            'hari' => 'Senin',
            'jam_mulai' => '08:00:00',
            'jam_selesai' => '10:30:00', // 3 SKS biasanya 2.5 jam
            'kuota' => 40
        ]);
    // buat jadwal beda hari
        Jadwal::create([
            'mata_kuliah_id' => $matkul->id,
            'dosen_id' => $dosen->id,
            'ruangan_id' => $ruangan->id,
            'semester_id' => $semester->id,
            'hari' => 'Senin',
            'jam_mulai' => '08:00:00',
            'jam_selesai' => '10:30:00', // 3 SKS biasanya 2.5 jam
            'kuota' => 30
        ]);
    }
}
