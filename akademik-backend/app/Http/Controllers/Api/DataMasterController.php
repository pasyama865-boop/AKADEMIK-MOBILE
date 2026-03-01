<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\Jadwal;
use App\Models\Mahasiswa;
use App\Models\MataKuliah;
use App\Models\Ruangan;
use App\Models\Semester;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;

/**
 * Controller untuk mengelola data master dan operasi CRUD dosen.
 * Juga menyediakan statistik ringkasan untuk dashboard admin.
 */
class DataMasterController extends Controller
{
    /**
     * Mengambil statistik ringkasan untuk dashboard admin.
     * Menghitung total data dari setiap entitas utama.
     */
    public function getAdminStats()
    {
        $stats = Cache::remember('admin_stats', now()->addMinutes(10), function () {
            return DB::selectOne("
                SELECT
                    (SELECT COUNT(*) FROM mahasiswas) as total_mahasiswa,
                    (SELECT COUNT(*) FROM dosens) as total_dosen,
                    (SELECT COUNT(*) FROM jadwals) as total_jadwal,
                    (SELECT COUNT(*) FROM mata_kuliahs) as total_matakuliah,
                    (SELECT COUNT(*) FROM ruangans) as total_ruangan,
                    (SELECT COUNT(*) FROM semesters) as total_semester,
                    (SELECT COUNT(*) FROM krs) as total_krs,
                    (SELECT COUNT(*) FROM users WHERE role = 'admin') as total_admin
            ");
        });

        return response()->json((array) $stats);
    }

    // ============================================================
    // CRUD DOSEN
    // ============================================================

    /**
     * Membuat data dosen baru beserta akun user terkait.
     *
     * Menggunakan database transaction untuk memastikan kedua proses
     * (pembuatan user dan profil dosen) berhasil secara atomik.
     */
    public function createDosen(Request $request)
    {
        $dataValid = $request->validate([
            'nama_lengkap' => 'required|string|max:255',
            'email'        => 'required|email|unique:users,email',
            'password'     => 'required|string|min:6',
            'nip'          => 'required|string|unique:dosens,nip',
            'gelar'        => 'nullable|string',
            'no_hp'        => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            // Buat akun user untuk dosen
            $user = User::create([
                'name'     => $dataValid['nama_lengkap'],
                'email'    => $dataValid['email'],
                'password' => Hash::make($dataValid['password']),
                'role'     => 'dosen',
            ]);

            // Buat profil dosen yang terhubung ke akun user
            $dosen = Dosen::create([
                'user_id' => $user->id,
                'nip'     => $dataValid['nip'],
                'gelar'   => $dataValid['gelar'],
                'no_hp'   => $dataValid['no_hp'],
            ]);

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Dosen berhasil ditambahkan',
                'data'    => $dosen,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal menyimpan data: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus data dosen beserta akun user terkait.
     *
     * Menggunakan database transaction karena melibatkan
     * penghapusan di dua tabel (dosens dan users).
     */
    public function deleteDosen($id)
    {
        DB::beginTransaction();

        try {
            $dosen = Dosen::find($id);

            if (!$dosen) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Data dosen tidak ditemukan',
                ], 404);
            }

            $userId = $dosen->user_id;
            $dosen->delete();

            // Hapus akun user jika ada
            if ($userId) {
                User::where('id', $userId)->delete();
            }

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data dosen beserta akun login berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal menghapus data: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui data dosen dan akun user terkait.
     *
     * Password hanya diperbarui jika diisi pada request.
     * Menggunakan database transaction untuk konsistensi data.
     */
    public function updateDosen(Request $request, $id)
    {
        // Cari data dosen berdasarkan ID
        $dosen = Dosen::find($id);

        if (!$dosen) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Dosen tidak ditemukan',
            ], 404);
        }

        $userId = $dosen->user_id;

        $dataValid = $request->validate([
            'nama_lengkap' => 'required|string|max:255',
            'email'        => 'required|email|unique:users,email,' . $userId,
            'password'     => 'nullable|string|min:6',
            'nip'          => 'required|string|unique:dosens,nip,' . $id,
            'gelar'        => 'nullable|string',
            'no_hp'        => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            // Perbarui data akun user
            $user = User::find($userId);
            $user->name  = $dataValid['nama_lengkap'];
            $user->email = $dataValid['email'];

            // Perbarui password hanya jika diisi
            if (!empty($dataValid['password'])) {
                $user->password = Hash::make($dataValid['password']);
            }
            $user->save();

            // Perbarui profil dosen
            $dosen->nip   = $dataValid['nip'];
            $dosen->gelar = $dataValid['gelar'];
            $dosen->no_hp = $dataValid['no_hp'];
            $dosen->save();

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data Dosen berhasil diperbarui',
                'data'    => $dosen,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal mengubah data: ' . $e->getMessage(),
            ], 500);
        }
    }
}
