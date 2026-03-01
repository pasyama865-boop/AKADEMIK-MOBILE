<?php

namespace Tests\Feature;

use App\Models\Dosen;
use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Mahasiswa;
use App\Models\MataKuliah;
use App\Models\Ruangan;
use App\Models\Semester;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Str;
use Tests\TestCase;

class KrsApiTest extends TestCase
{
    use DatabaseMigrations;

    private $user;
    private $mahasiswa;
    private $semester;
    private $ruangan;
    private $dosen;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Setup User & Mahasiswa
        $this->user = User::create([
            'name'     => 'Test Student',
            'email'    => 'student@test.com',
            'password' => bcrypt('password123'),
            'role'     => 'mahasiswa',
            'nim_nip'  => '12345678',
        ]);

        $this->mahasiswa = Mahasiswa::create([
            'user_id'  => $this->user->id,
            'nim'      => '12345678',
            'jurusan'  => 'Teknik Informatika',
            'angkatan' => '2023',
        ]);

        // 2. Setup Master Data
        $this->semester = Semester::create([
            'nama'            => 'Ganjil 2026',
            'tanggal_mulai'   => '2026-08-01',
            'tanggal_selesai' => '2027-01-31',
            'is_active'       => true,
        ]);

        $this->ruangan = Ruangan::create([
            'nama'      => 'Lab Komputer A',
            'gedung'    => 'Gedung IT',
            'kapasitas' => 40,
        ]);

        $dosenUser = User::create([
            'name'     => 'Dr. Dosen',
            'email'    => 'dosen@test.com',
            'password' => bcrypt('password'),
            'role'     => 'dosen',
            'nim_nip'  => '987654321',
        ]);

        $this->dosen = Dosen::create([
            'user_id' => $dosenUser->id,
            'nip'     => '987654321',
            'gelar'   => 'M.Kom',
            'no_hp'   => '08123456789',
        ]);
    }

    /**
     * Test KRS Berhasil (Happy Path)
     */
    public function test_mahasiswa_dapat_mengambil_krs_dengan_sukses()
    {
        $matkul = MataKuliah::create([
            'kode_matkul'    => 'IF101',
            'nama_matkul'    => 'Algoritma',
            'sks'            => 3,
            'semester_paket' => 1,
        ]);

        $jadwal = Jadwal::create([
            'mata_kuliah_id' => $matkul->id,
            'ruangan_id'     => $this->ruangan->id,
            'semester_id'    => $this->semester->id,
            'dosen_id'       => $this->dosen->user_id,
            'hari'           => 'Senin',
            'jam_mulai'      => '08:00:00',
            'jam_selesai'    => '10:30:00',
            'kuota'          => 40,
        ]);

        $response = $this->actingAs($this->user)->postJson('/api/krs', [
            'jadwal_id' => $jadwal->id,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'message' => 'Berhasil mengambil mata kuliah!',
            ]);

        $this->assertDatabaseHas('krs', [
            'mahasiswa_id' => $this->mahasiswa->id,
            'jadwal_id'    => $jadwal->id,
        ]);
    }

    /**
     * Test Validasi Bentrok Jadwal
     */
    public function test_krs_ditolak_jika_jadwal_bentrok()
    {
        $matkul1 = MataKuliah::create(['kode_matkul' => 'IF1', 'nama_matkul' => 'Matkul 1', 'sks' => 3, 'semester_paket' => 1]);
        $matkul2 = MataKuliah::create(['kode_matkul' => 'IF2', 'nama_matkul' => 'Matkul 2', 'sks' => 3, 'semester_paket' => 1]);

        $jadwal1 = Jadwal::create([
            'mata_kuliah_id' => $matkul1->id, 'ruangan_id' => $this->ruangan->id, 
            'semester_id' => $this->semester->id, 'dosen_id' => $this->dosen->user_id,
            'hari' => 'Selasa', 'jam_mulai' => '08:00:00', 'jam_selesai' => '10:00:00', 'kuota' => 40,
        ]);

        $jadwal2 = Jadwal::create([
            'mata_kuliah_id' => $matkul2->id, 'ruangan_id' => $this->ruangan->id, 
            'semester_id' => $this->semester->id, 'dosen_id' => $this->dosen->user_id,
            'hari' => 'Selasa', 'jam_mulai' => '09:00:00', 'jam_selesai' => '11:00:00', 'kuota' => 40, // Waktu Beririsan
        ]);

        // Ambil kelas pertama (Sukses)
        $this->actingAs($this->user)->postJson('/api/krs', ['jadwal_id' => $jadwal1->id])->assertStatus(201);

        // Ambil kelas kedua dengan waktu beririsan (Gagal/Bentrok)
        $response = $this->actingAs($this->user)->postJson('/api/krs', ['jadwal_id' => $jadwal2->id]);
        
        $response->assertStatus(400)
            ->assertJson([
                'message' => 'Jadwal Bentrok!',
            ]);
    }

    /**
     * Test Validasi Lebih Dari 24 SKS
     */
    public function test_krs_ditolak_jika_lebih_dari_24_sks()
    {
        $matkulBesar = MataKuliah::create(['kode_matkul' => 'IF99', 'nama_matkul' => 'Tugas Akhir', 'sks' => 24, 'semester_paket' => 8]);
        $jadwalBesar = Jadwal::create([
            'mata_kuliah_id' => $matkulBesar->id, 'ruangan_id' => $this->ruangan->id, 
            'semester_id' => $this->semester->id, 'dosen_id' => $this->dosen->user_id,
            'hari' => 'Senin', 'jam_mulai' => '08:00:00', 'jam_selesai' => '12:00:00', 'kuota' => 20,
        ]);

        $matkulLebih = MataKuliah::create(['kode_matkul' => 'IF100', 'nama_matkul' => 'Kelebihan', 'sks' => 2, 'semester_paket' => 8]);
        $jadwalLebih = Jadwal::create([
            'mata_kuliah_id' => $matkulLebih->id, 'ruangan_id' => $this->ruangan->id, 
            'semester_id' => $this->semester->id, 'dosen_id' => $this->dosen->user_id,
            'hari' => 'Selasa', 'jam_mulai' => '13:00:00', 'jam_selesai' => '15:00:00', 'kuota' => 20,
        ]);

        // Ambil 24 SKS (Sukses)
        $this->actingAs($this->user)->postJson('/api/krs', ['jadwal_id' => $jadwalBesar->id])->assertStatus(201);

        // Ambil tambah 2 SKS jadi 26 SKS (Gagal)
        $response = $this->actingAs($this->user)->postJson('/api/krs', ['jadwal_id' => $jadwalLebih->id]);

        $response->assertStatus(400)
            ->assertJsonFragment([
                'message' => 'Melebihi batas 24 SKS!',
            ]);
    }
}
