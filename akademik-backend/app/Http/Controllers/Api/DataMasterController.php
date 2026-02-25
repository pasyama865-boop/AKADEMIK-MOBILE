<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use App\Models\Jadwal;
use App\Models\MataKuliah;
use App\Models\Ruangan;
use App\Models\Semester;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DataMasterController extends Controller
{
    public function getAdminStats()
    {
        $totalMahasiswa = Mahasiswa::count();
        $totalDosen = Dosen::count();
        $totalJadwal = Jadwal::count();
        $totalMataKuliah = MataKuliah::count();
        $totalRuangan = Ruangan::count();
        $totalSemester = Semester::count();

        return response()->json([
            'total_mahasiswa' => $totalMahasiswa,
            'total_dosen' => $totalDosen,
            'total_jadwal' => $totalJadwal,
            'total_matakuliah' => $totalMataKuliah,
            'total_ruangan' => $totalRuangan,
            'total_semester' => $totalSemester,
        ]);
    }

    // Fungsi untuk menerima data Dosen
    public function createDosen(Request $request)
    {
        $validated = $request->validate([
            'nama_lengkap' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'nip' => 'required|string|unique:dosens,nip',
            'gelar' => 'nullable|string',
            'no_hp' => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            // PROSES A: Buat akun User dulu
            $user = User::create([
            'name' => $validated['nama_lengkap'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'dosen',
        ]);

        // Jika A dan B sukses, COMMIT (Sahkan dan simpan permanen ke database)
            $dosen = Dosen::create([
            'user_id' => $user->id,
            'nip' => $validated['nip'],
            'gelar' => $validated['gelar'],
            'no_hp' => $validated['no_hp'],
            ]);

            // Jika A dan B sukses, COMMIT Sahkan dan simpan permanen ke database
            DB::commit();

            return response()->json([
                'status' => 'success',
                'message' => 'Dosen berhasil ditambahkan',
                'data' => $dosen
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menyimpan data:' . $e->getMessage()
            ], 500);
        }
    }

    // Fungsi untuk menghapus data dosen
    public function deleteDosen($id)
    {
        DB::beginTransaction();

        try {
            $dosen = Dosen::find($id);
            if (!$dosen) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data dosen tidak ditemukan'
                ], 404);
            }

            $userId = $dosen->user_id;
            $dosen->delete();

            if ($userId) {
                User::where('id', $userId)->delete();
            }

            DB::commit();
            return response()->json([
                'status' => 'success',
                'message' => 'Data dosen beserta akun loin berhasil dihapus'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus data:' . $e->getMessage()
            ], 500);
        }
    }

    // Fungsi untuk mengubah data dosen
    public function updateDosen(Request $request, $id)
    {
        // 1. Cari dulu dosennya ada atau tidak
        $dosen = Dosen::find($id);
        if (!$dosen) {
            return response()->json(['status' => 'error', 'message' => 'Dosen tidak ditemukan'], 404);
        }

        $userId = $dosen->user_id;
        $validated = $request->validate([
            'nama_lengkap'  => 'required|string|max:255',
            'email'         => 'required|email|unique:users,email,' . $userId,
            'password'      => 'nullable|string|min:6',
            'nip'           => 'required|string|unique:dosens,nip,' . $id,
            'gelar'         => 'nullable|string',
            'no_hp'         => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            // 3. Update data Akun User
            $user = User::find($userId);
            $user->name = $validated['nama_lengkap'];
            $user->email = $validated['email'];

            // Jika kolom password diisi, maka update passwordnya. Jika kosong, biarkan yang lama.
            if (!empty($validated['password'])) {
                $user->password = Hash::make($validated['password']);
            }
            $user->save();

            // 4. Update profil Dosen
            $dosen->nip = $validated['nip'];
            $dosen->gelar = $validated['gelar'];
            $dosen->no_hp = $validated['no_hp'];
            $dosen->save(); // Simpan perubahan Dosen

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'Data Dosen berhasil diperbarui',
                'data'    => $dosen
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal mengubah data: ' . $e->getMessage()
            ], 500);
        }
    }
}
