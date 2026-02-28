<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\Jadwal;
use Illuminate\Support\Facades\Auth;

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
}

