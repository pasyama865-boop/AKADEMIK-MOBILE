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
            ->with(['mataKuliah', 'krs'])
            ->withCount('krs')
            ->get();

        $totalKelas = $jadwalList->count();
        $totalMahasiswa = $jadwalList->sum('krs_count');

        $nilaiDraft = 0;
        $krsWithNilaiCount = 0;
        
        $gradesCount = ['A' => 0, 'B' => 0, 'C' => 0, 'D' => 0, 'E' => 0];

        $kelasRekap = [];

        foreach($jadwalList as $jadwal) {
            $hasUnpublishedNilai = false;
            $classGrades = ['A' => 0, 'B' => 0, 'C' => 0, 'D' => 0, 'E' => 0];

            foreach($jadwal->krs as $krs) {
                if(empty($krs->nilai_akhir)) {
                    $hasUnpublishedNilai = true;
                } else {
                    $krsWithNilaiCount++;
                    $grade = strtoupper(trim($krs->nilai_akhir));
                    if (isset($gradesCount[$grade])) {
                        $gradesCount[$grade]++;
                    }
                    if (isset($classGrades[$grade])) {
                        $classGrades[$grade]++;
                    }
                }
            }
            if ($hasUnpublishedNilai && $jadwal->krs->count() > 0) {
                $nilaiDraft++;
            }

            $kelasRekap[] = [
                'nama_matkul' => $jadwal->mataKuliah ? $jadwal->mataKuliah->nama_matkul : 'Unknown',
                'total_mahasiswa' => $jadwal->krs_count,
                'distribusi' => $classGrades
            ];
        }

        $publikasiPersen = $totalMahasiswa > 0 ? round(($krsWithNilaiCount / $totalMahasiswa) * 100) : 0;

        $krsPending = 0;
        if ($user->dosen) {
            $mahasiswaIds = Mahasiswa::where('dosen_id', $user->dosen->id)->pluck('id');
            $krsPending = Krs::whereIn('mahasiswa_id', $mahasiswaIds)->where('status', 'pending')->count();
        }

        return response()->json([
            'total_kelas' => $totalKelas,
            'total_mahasiswa' => $totalMahasiswa,
            'krs_pending' => $krsPending,
            'nilai_draft' => $nilaiDraft,
            'publikasi_persen' => $publikasiPersen,
            'distribusi_nilai' => $gradesCount,
            'kelas_rekap' => $kelasRekap,
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

    /**
     * Dosen: Mengambil daftar mahasiswa yang tergabung dalam suatu kelas/jadwal.
     */
    public function getKelasMahasiswa($jadwalId)
    {
        $user = Auth::user();
        if (!$user->dosen) {
            return response()->json(['message' => 'Anda bukan Dosen'], 403);
        }

        // Verifikasi jadwal ini milik dosen ybs
        $jadwal = Jadwal::where('id', $jadwalId)->where('dosen_id', $user->id)->first();
        if (!$jadwal) {
            return response()->json(['message' => 'Kelas tidak ditemukan atau Anda tidak mengajar kelas ini'], 404);
        }

        // Ambil mahasiswa yang krs nya on jadwal tsb
        $krsList = Krs::where('jadwal_id', $jadwalId)
            ->with(['mahasiswa.user'])
            ->get()
            ->map(function ($krs) {
                return [
                    'krs_id' => $krs->id,
                    'status' => $krs->status,
                    'nim' => $krs->mahasiswa->nim ?? '-',
                    'nama' => $krs->mahasiswa->user->name ?? '-',
                    'nilai_akhir' => $krs->nilai_akhir,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data'   => $krsList,
        ]);
    }

    /**
     * Dosen: Menginputkan nilai ke rekaman KRS
     */
    public function inputNilai(Request $request, $krsId)
    {
        $request->validate([
            'nilai_akhir' => 'required|string|in:A,B,C,D,E'
        ]);

        $user = Auth::user();
        if (!$user->dosen) {
            return response()->json(['message' => 'Anda bukan Dosen'], 403);
        }

        $krs = Krs::where('id', $krsId)->with('jadwal')->first();
        if (!$krs || !$krs->jadwal || $krs->jadwal->dosen_id !== $user->id) {
            return response()->json(['message' => 'KRS/Mata Kuliah tidak ditemukan atau itu bukan kelas Anda'], 404);
        }

        $krs->nilai_akhir = $request->nilai_akhir;
        $krs->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Nilai berhasil disimpan.',
            'data' => $krs
        ]);
    }
}

