<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ruangan;
use Illuminate\Http\Request;

class RuanganController extends Controller
{
    // 1. GET LIST RUANGAN
    public function getRuanganList()
    {
        $ruangans = Ruangan::orderBy('nama', 'asc')->get();
        return response()->json([
            'status' => 'success',
            'message' => 'Data ruangan berhasil diambil',
            'data' => $ruangans
        ]);
    }

    // 2. CREATE RUANGAN
    public function createRuangan(Request $request)
    {
        $validated = $request->validate([
            'nama'   => 'required|string|max:255',
            'gedung' => 'nullable|string|max:255',
            'kapasitas' => 'required|numeric|min:1',
        ]);

        try {
            $ruangan = Ruangan::create($validated);
            return response()->json([
                'status' => 'success',
                'message' => 'Ruangan berhasil ditambahkan',
                'data' => $ruangan
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // 3. UPDATE RUANGAN
    public function updateRuangan(Request $request, $id)
    {
        $ruangan = Ruangan::find($id);
        if (!$ruangan) return response()->json(['message' => 'Ruangan tidak ditemukan'], 404);

        $validated = $request->validate([
            'nama'   => 'required|string|max:255',
            'gedung' => 'nullable|string|max:255',
            'kapasitas' => 'required|numeric|min:1',
        ]);

        try {
            $ruangan->update($validated);
            return response()->json(['status' => 'success', 'message' => 'Ruangan berhasil diperbarui', 'data' => $ruangan]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // 4. DELETE RUANGAN
    public function deleteRuangan($id)
    {
        $ruangan = Ruangan::find($id);
        if (!$ruangan) return response()->json(['message' => 'Ruangan tidak ditemukan'], 404);

        try {
            $ruangan->delete();
            return response()->json(['status' => 'success', 'message' => 'Ruangan berhasil dihapus']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Ruangan gagal dihapus, mungkin sedang digunakan di Jadwal.'], 500);
        }
    }
}
