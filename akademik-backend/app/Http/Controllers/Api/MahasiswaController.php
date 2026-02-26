<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Controller untuk mengelola data mahasiswa.
 * Setiap operasi CRUD mahasiswa juga melibatkan akun user terkait.
 */
class MahasiswaController extends Controller
{
    /**
     * Mengambil seluruh daftar mahasiswa beserta data user terkait.
     */
    public function getMahasiswaList()
    {
        $daftarMahasiswa = Mahasiswa::with('user')->get();

        return response()->json([
            'message' => 'Data mahasiswa berhasil diambil',
            'data'    => $daftarMahasiswa,
        ]);
    }

    /**
     * Membuat data mahasiswa baru beserta akun user terkait.
     *
     * Menggunakan database transaction karena melibatkan
     * pembuatan data di dua tabel (users dan mahasiswas).
     */
    public function createMahasiswa(Request $request)
    {
        $dataValid = $request->validate([
            'nama_user'     => 'required|string|max:255',
            'email_user'    => 'required|email|unique:users,email',
            'password_user' => 'required|string|min:6',
            'nim'           => 'required|string|unique:mahasiswas,nim',
            'jurusan'       => 'required|string',
            'angkatan'      => 'required|numeric',
        ]);

        DB::beginTransaction();

        try {
            // Buat akun user untuk mahasiswa
            $user = User::create([
                'name'     => $dataValid['nama_user'],
                'email'    => $dataValid['email_user'],
                'password' => Hash::make($dataValid['password_user']),
                'role'     => 'mahasiswa',
            ]);

            // Buat profil mahasiswa yang terhubung ke akun user
            $mahasiswaBaru = Mahasiswa::create([
                'user_id'  => $user->id,
                'nim'      => $dataValid['nim'],
                'jurusan'  => $dataValid['jurusan'],
                'angkatan' => $dataValid['angkatan'],
            ]);

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Mahasiswa berhasil ditambahkan',
                'data'    => $mahasiswaBaru,
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
     * Memperbarui data mahasiswa dan akun user terkait.
     *
     * Password hanya diperbarui jika diisi pada request.
     * Menggunakan database transaction untuk konsistensi data.
     */
    public function updateMahasiswa(Request $request, $id)
    {
        $mahasiswa = Mahasiswa::find($id);

        if (!$mahasiswa) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data mahasiswa tidak ditemukan',
            ], 404);
        }

        $userId = $mahasiswa->user_id;

        $dataValid = $request->validate([
            'nama_user'     => 'required|string|max:255',
            'email_user'    => 'required|email|unique:users,email,' . $userId,
            'password_user' => 'nullable|string|min:6',
            'nim'           => 'required|string|unique:mahasiswas,nim,' . $id,
            'jurusan'       => 'required|string',
            'angkatan'      => 'required|numeric',
        ]);

        DB::beginTransaction();

        try {
            // Perbarui data akun user
            $user = User::find($userId);
            $user->name  = $dataValid['nama_user'];
            $user->email = $dataValid['email_user'];

            // Perbarui password hanya jika diisi
            if (!empty($dataValid['password_user'])) {
                $user->password = Hash::make($dataValid['password_user']);
            }
            $user->save();

            // Perbarui data profil mahasiswa
            $mahasiswa->nim      = $dataValid['nim'];
            $mahasiswa->jurusan  = $dataValid['jurusan'];
            $mahasiswa->angkatan = $dataValid['angkatan'];
            $mahasiswa->save();

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data mahasiswa berhasil diperbarui',
                'data'    => $mahasiswa,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal mengubah data: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus data mahasiswa beserta akun user terkait.
     *
     * Menggunakan database transaction karena melibatkan
     * penghapusan di dua tabel (mahasiswas dan users).
     */
    public function deleteMahasiswa($id)
    {
        DB::beginTransaction();

        try {
            $mahasiswa = Mahasiswa::find($id);

            if (!$mahasiswa) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Data mahasiswa tidak ditemukan',
                ], 404);
            }

            $userId = $mahasiswa->user_id;
            $mahasiswa->delete();

            // Hapus akun user jika ada
            if ($userId) {
                User::where('id', $userId)->delete();
            }

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data mahasiswa beserta akun berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal menghapus data: ' . $e->getMessage(),
            ], 500);
        }
    }
}
