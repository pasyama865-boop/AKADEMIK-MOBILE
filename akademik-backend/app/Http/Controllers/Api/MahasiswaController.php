<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;


class MahasiswaController extends Controller
{
    // Mengambil semua data dari tabel mahasiswa
    public function getMahasiswaList()
    {
        $mahasiswa = Mahasiswa::with(
            'user')
            ->get();
            return response()->json([
                'message' => 'Data mahasiswa berhasil diambil',
                'data' => $mahasiswa,
            ]);
    }

    // Membuat mahasiswa
    public function createMahasiswa(Request $request)
    {
        $validated = $request->validate([
            'nama_user' => 'required|string|max:255',
            'email_user' => 'required|email|unique:users,email',
            'password_user' => 'required|string|min:6',
            'nim' => 'required|string|unique:mahasiswas,nim',
            'jurusan' => 'required|string',
            'angkatan' => 'required|numeric',
        ]);

        DB::beginTransaction();
        try {
            // Proses A : Membuat user
            $user = User::create([
                'name' => $validated['nama_user'],
                'email' => $validated['email_user'],
                'password' => Hash::make($validated['password_user']),
                'role'  => 'mahasiswa',
            ]);
            // Proses B : Membuat profil mahasiswa
            $mhs = Mahasiswa::create([
                'user_id' => $user->id,
                'nim' => $validated['nim'],
                'jurusan' => $validated['jurusan'],
                'angkatan' => $validated['angkatan'],
            ]);

            DB::commit();
            return response()->json([
                'status' => 'error',
                'message' => 'Mahasiswa berhasil ditambahkan',
                'data' => $mhs,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menyimpan data: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateMahasiswa(Request $request, $id)
    {
        $mhs = Mahasiswa::find($id);
        if (!$mhs) {
            return response()->json([
                'status' => 'error',
                'message' => 'Data mahasiswa tidak ditemukan'
            ], 404);

        $userId = $mhs->user_id;

        $validated = $request->validate([
            'nama_user' => 'required|string|max:255',
            'email_user' => 'required|email|unique:users,email,' . $userId,
            'password_user' => 'nullable|string|min:6',
            'nim' => 'required|string|unique:mahasiswas,nim,' . $id,
            'jurusan' => 'required|string',
            'angkatan' => 'required|numeric',
        ]);

        DB::beginTransaction();
        try {
            // Proses A : Update user
            $user = User::find($userId);
            $user->name = $validated['nama_user'];
            $user->email = $validated['email_user'];
            if (!empty($validated['password_user'])) {
                $user->password = Hash::make($validated['password_user']);
            }
            $user->save();

            // Update mahasiswa
            $mhs->nim = $validated['nim'];
            $mhs->jurusan = $validated['jurusan'];
            $mhs->angkatan = $validated['angkatan'];
            $mhs->save();

            DB::commit();
            return response()->json([
                'status' => 'success',
                'message' => 'Data mahasiswa berhasil diperbarui',
                'data' => $mhs,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengubah data: ' . $e->getMessage()
                ], 500);
            }
        }
    }

    public function deleteMahasiswa($id)
    {
        DB::beginTransaction();
        try {
            $mhs = Mahasiswa::find($id);
            if (!$mhs) return response()->json([
                'status' => 'error',
                'message' => 'Data mahasiswa tidak ditemukan'
            ], 404);
            $userId = $mhs->user_id;
            $mhs->delete();
            if ($userId) {
                User::where('id', $userId)->delete();
            }
            DB::commit();
            return response()->json([
                'status' => 'success',
                'message' => 'Data mahasiswa beserta akun berhasil dihapus'
            ]);
            } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus data: ' . $e->getMessage()
            ], 500);
            }
    }
}
