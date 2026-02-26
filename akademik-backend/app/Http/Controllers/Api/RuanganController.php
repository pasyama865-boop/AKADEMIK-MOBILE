<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ruangan;
use Illuminate\Http\Request;

/**
 * Controller untuk mengelola data ruangan.
 * Menyediakan operasi CRUD lengkap untuk entitas ruangan.
 */
class RuanganController extends Controller
{
    /**
     * Mengambil seluruh daftar ruangan, diurutkan berdasarkan nama (A-Z).
     */
    public function getRuanganList()
    {
        $daftarRuangan = Ruangan::orderBy('nama', 'asc')->get();

        return response()->json([
            'status'  => 'success',
            'message' => 'Data ruangan berhasil diambil',
            'data'    => $daftarRuangan,
        ]);
    }

    /**
     * Membuat data ruangan baru.
     */
    public function createRuangan(Request $request)
    {
        $dataValid = $request->validate([
            'nama'      => 'required|string|max:255',
            'gedung'    => 'nullable|string|max:255',
            'kapasitas' => 'required|numeric|min:1',
        ]);

        try {
            $ruanganBaru = Ruangan::create($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Ruangan berhasil ditambahkan',
                'data'    => $ruanganBaru,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui data ruangan berdasarkan ID.
     */
    public function updateRuangan(Request $request, $id)
    {
        $ruangan = Ruangan::find($id);

        if (!$ruangan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Ruangan tidak ditemukan',
            ], 404);
        }

        $dataValid = $request->validate([
            'nama'      => 'required|string|max:255',
            'gedung'    => 'nullable|string|max:255',
            'kapasitas' => 'required|numeric|min:1',
        ]);

        try {
            $ruangan->update($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Ruangan berhasil diperbarui',
                'data'    => $ruangan,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus data ruangan berdasarkan ID.
     * Akan gagal jika ruangan sedang digunakan di jadwal.
     */
    public function deleteRuangan($id)
    {
        $ruangan = Ruangan::find($id);

        if (!$ruangan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Ruangan tidak ditemukan',
            ], 404);
        }

        try {
            $ruangan->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Ruangan berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Ruangan gagal dihapus, mungkin sedang digunakan di Jadwal.',
            ], 500);
        }
    }
}
