<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Semester;
use Illuminate\Http\Request;

/**
 * Controller untuk mengelola data semester.
 * Menyediakan operasi CRUD lengkap untuk entitas semester.
 */
class SemesterController extends Controller
{
    /**
     * Mengambil seluruh daftar semester.
     */
    public function getSemesterList()
    {
        $daftarSemester = Semester::all();

        return response()->json([
            'status' => 'success',
            'data'   => $daftarSemester,
        ]);
    }

    /**
     * Membuat data semester baru.
     */
    public function createSemester(Request $request)
    {
        $dataValid = $request->validate([
            'nama'            => 'required|string|max:255',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date',
            'is_active'       => 'boolean',
        ]);

        try {
            $dataValid['is_active'] = $request->is_active ?? false;
            $semesterBaru = Semester::create($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Semester berhasil ditambahkan',
                'data'    => $semesterBaru,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui data semester berdasarkan ID.
     */
    public function updateSemester(Request $request, $id)
    {
        $semester = Semester::find($id);

        if (!$semester) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Semester tidak ditemukan',
            ], 404);
        }

        $dataValid = $request->validate([
            'nama'            => 'required|string|max:255',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date',
            'is_active'       => 'boolean',
        ]);

        try {
            $dataValid['is_active'] = $request->is_active ?? false;
            $semester->update($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Semester berhasil diperbarui',
                'data'    => $semester,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus data semester berdasarkan ID.
     */
    public function deleteSemester($id)
    {
        $semester = Semester::find($id);

        if (!$semester) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Semester tidak ditemukan',
            ], 404);
        }

        try {
            $semester->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Semester berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
