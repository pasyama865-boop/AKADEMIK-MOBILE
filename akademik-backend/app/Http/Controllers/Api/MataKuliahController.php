<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MataKuliah;
use Illuminate\Http\Request;

/**
 * Controller untuk mengelola data mata kuliah.
 * Menyediakan operasi CRUD lengkap untuk entitas mata kuliah.
 */
class MataKuliahController extends Controller
{
    /**
     * Mengambil seluruh daftar mata kuliah.
     */
    public function getMataKuliahList()
    {
        $daftarMatkul = MataKuliah::all();

        return response()->json([
            'status' => 'success',
            'data'   => $daftarMatkul,
        ]);
    }

    /**
     * Membuat data mata kuliah baru.
     */
    public function createMataKuliah(Request $request)
    {
        $dataValid = $request->validate([
            'kode_matkul'    => 'required|string|max:10|unique:mata_kuliahs,kode_matkul',
            'nama_matkul'    => 'required|string|max:255',
            'sks'            => 'required|numeric|min:1|max:6',
            'semester_paket' => 'required|numeric|min:1|max:8',
        ]);

        try {
            $matkulBaru = MataKuliah::create($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Mata Kuliah ditambahkan',
                'data'    => $matkulBaru,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui data mata kuliah berdasarkan ID.
     */
    public function updateMataKuliah(Request $request, $id)
    {
        $matkul = MataKuliah::find($id);

        if (!$matkul) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Mata Kuliah tidak ditemukan',
            ], 404);
        }

        $dataValid = $request->validate([
            'kode_matkul'    => 'required|string|max:10|unique:mata_kuliahs,kode_matkul,' . $id,
            'nama_matkul'    => 'required|string|max:255',
            'sks'            => 'required|numeric|min:1|max:6',
            'semester_paket' => 'required|numeric|min:1|max:8',
        ]);

        try {
            $matkul->update($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Mata Kuliah diperbarui',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus data mata kuliah berdasarkan ID.
     */
    public function deleteMataKuliah($id)
    {
        $matkul = MataKuliah::find($id);

        if (!$matkul) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Mata Kuliah tidak ditemukan',
            ], 404);
        }

        try {
            $matkul->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Mata Kuliah dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
