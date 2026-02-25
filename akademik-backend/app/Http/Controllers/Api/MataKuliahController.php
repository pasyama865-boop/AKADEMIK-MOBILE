<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MataKuliah;
use Illuminate\Http\Request;
class MataKuliahController extends Controller
{
    // Mengambil semua data dari tabel mata_kuliahs
    public function getMataKuliahList()
    {
        $matkul = MataKuliah::all();

        return response()->json([
            'status' => 'success',
            'data' => $matkul,
        ], 200);
    }

    // Membuat mata kuliah
    public function createMataKuliah(Request $request)
    {
        $validated = $request->validate([
            'kode_matkul'    => 'required|string|max:10|unique:mata_kuliahs,kode_matkul',
            'nama_matkul'    => 'required|string|max:255',
            'sks'            => 'required|numeric|min:1|max:6',
            'semester_paket' => 'required|numeric|min:1|max:8',
        ]);

        try {
            $matkul = MataKuliah::create($validated);
            return response()->json(['status' => 'success', 'message' => 'Mata Kuliah ditambahkan', 'data' => $matkul], 201);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // Update mata kuliah
    public function updateMataKuliah(Request $request, $id)
    {
        $matkul = MataKuliah::find($id);
        if (!$matkul) return response()->json(['message' => 'Mata Kuliah tidak ditemukan'], 404);

        $validated = $request->validate([
            'kode_matkul'    => 'required|string|max:10|unique:mata_kuliahs,kode_matkul,' . $id,
            'nama_matkul'    => 'required|string|max:255',
            'sks'            => 'required|numeric|min:1|max:6',
            'semester_paket' => 'required|numeric|min:1|max:8',
        ]);

        try {
            $matkul->update($validated);
            return response()->json(['status' => 'success', 'message' => 'Mata Kuliah diperbarui']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // Hapus mata kuliah
    public function deleteMataKuliah($id)
    {
        try {
            $matkul = MataKuliah::find($id);
            if (!$matkul) return response()->json(['message' => 'Mata Kuliah tidak ditemukan'], 404);

            $matkul->delete(); 
            return response()->json(['status' => 'success', 'message' => 'Mata Kuliah dihapus']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

}
