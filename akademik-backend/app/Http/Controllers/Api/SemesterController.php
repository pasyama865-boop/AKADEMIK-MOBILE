<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Semester;
use Illuminate\Http\Request;


class SemesterController extends Controller
{
        // Mengambil semua data dari tabel semester
    public function getSemesterList()
    {
        $semester = Semester::all();

        return response()->json([
            'status' => 'success',
            'data' => $semester,
        ], 200);
    }

    public function createSemester(Request $request)
    {
        $validated = $request->validate([
            'nama_semester' => 'required|string|max:255',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date',
            'is_active' => 'required|boolean',
        ]);

        try {
            $validated['is_active'] = $request->is_active ?? false;
            $semester = Semester::create($validated);
            return response()->json([
                'status' => 'success',
                'message' => 'Semester berhasil ditambahkan',
                'data' => $semester,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function updateSemester(Request $request, $id)
    {
        $semester = Semester::find($id);
        if (!$semester) {
            return response()->json([
                'status' => 'error',
                'message' => 'Semester tidak ditemukan',
            ], 404);

            $validated = $request->validate([
                'nama' => 'required|string|max:255',
                'tanggal_mulai' => 'required|date',
                'tanggal_selesai' => 'required|date',
                'is_active' => 'required|boolean',
            ]);

            try {
                $validated['is_active'] = $request->is_active ?? false;
                $semester->update($validated);
                return response()->json([
                    'status' => 'success',
                    'message' => 'Semester berhasil diperbarui',
                    'data' => $semester,
                ]);
            } catch (\Exception $e) {
                return response()->json([
                    'status' => 'error',
                    'message' => $e->getMessage(),
                ], 500);
            }
        }
    }

    public function deleteSemester($id)
    {
        $semester = Semester::find($id);
        if (!$semester) {
            return response()->json([
                'status' => 'error',
                'message'=> 'Semester tidak ditemukan',
            ], 404);
        }

        try {
            $semester->delete();
            return response()->json([
                'status' => 'success',
                'message' => 'Semester berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message'=> $e->getMessage(),
            ], 500);
        }

    }
}
