<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Mahasiswa;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

/**
 * Controller untuk mengambil data dosen.
 * Operasi CRUD dosen berada di DataMasterController.
 */
class DosenController extends Controller
{
    /**
     * Mengambil seluruh daftar dosen beserta data user terkait.
     */
    public function getDosenList()
    {
        $daftarDosen = Dosen::with('user')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $daftarDosen,
        ]);
    }

    /**
     * Mengambil jadwal milik dosen yang sedang login.
     */
    public function getMyJadwal()
    {
        $user = Auth::user();

        $jadwal = Jadwal::where('dosen_id', $user->id)
            ->with(['mataKuliah', 'ruangan', 'semester'])
            ->withCount('krs')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $jadwal,
        ]);
    }

    /**
     * Mengambil statistik ringkasan untuk dashboard dosen.
     */
    public function getMyStats()
    {
        $user = Auth::user();

        $jadwalList = Jadwal::where('dosen_id', $user->id)
            ->with('mataKuliah')
            ->withCount('krs')
            ->get();

        $totalKelas = $jadwalList->count();
        $totalMahasiswa = $jadwalList->sum('krs_count');
        $totalSks = $jadwalList->sum(function ($j) {
            return $j->mataKuliah ? $j->mataKuliah->sks : 0;
        });

        return response()->json([
            'total_kelas' => $totalKelas,
            'total_mahasiswa' => $totalMahasiswa,
            'total_sks' => $totalSks,
        ]);
    }

    /**
     * Dosen Wali: Mengambil daftar mahasiswa bimbingan & peringatan IP rendah.
     */
    public function getMahasiswaBimbingan()
    {
        $user = Auth::user();
        if (!$user->dosen) {
            return response()->json(['message' => 'Anda bukan Dosen'], 403);
        }

        $mahasiswa = Mahasiswa::where('dosen_id', $user->dosen->id)
            ->with(['user', 'krs.jadwal.mataKuliah']) // Load krs untuk cek status nantinya
            ->get();
            
        // Simulasi kalkulasi IPK / Peringatan (bisa diadopsi dari aggregate table KHS di kemudian hari)
        $dataMahasiswa = $mahasiswa->map(function($m) {
            $rataRataNilai = 3.0; // Mock simulasi IP sementara, karena modul KHS utuh belum fix.
            return [
                'id' => $m->id,
                'nim' => $m->nim,
                'nama' => $m->user->name ?? 'Unknown',
                'ip_sementara' => $rataRataNilai,
                'status_warning' => $rataRataNilai < 2.0 ? 'Peringatan: IP Rendah, rentan Drop Out' : 'Aman',
                'krs_pending_count' => $m->krs->where('status', 'pending')->count(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data'   => $dataMahasiswa,
        ]);
    }

    /**
     * Dosen Wali: Menyetujui semua KRS berstatus 'pending' milik mahasiswa tertentu.
     */
    public function approveKrsMahasiswa(Request $request, $mahasiswaId)
    {
        $user = Auth::user();
        if (!$user->dosen) {
            return response()->json(['message' => 'Anda bukan Dosen'], 403);
        }

        // Pastikan mahasiswa tsb adalah bimbingan dosen ini
        $mahasiswa = Mahasiswa::where('id', $mahasiswaId)
            ->where('dosen_id', $user->dosen->id)
            ->first();

        if (!$mahasiswa) {
            return response()->json(['message' => 'Mahasiswa tidak ditemukan atau bukan bimbingan Anda'], 404);
        }

        // Lakukan setuju semua krs pending
        $affected = Krs::where('mahasiswa_id', $mahasiswaId)
            ->where('status', 'pending')
            ->update(['status' => 'approved']);

        return response()->json([
            'status' => 'success',
            'message' => "Berhasil menyetujui $affected mata kuliah KRS untuk mahasiswa {$mahasiswa->user->name}",
        ]);
    }
}

