<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use Illuminate\Http\Request;

class JadwalController extends Controller
{
    // Mengambil semua data dari tabel jadwal
    public function getJadwalList()
    {
        $jadwal = Jadwal::with([
            'mataKuliah',
            'dosen',
            'semester',
            'ruangan'
        ])->latest()->get();

        return response()->json([
            'message' => 'Jadwal kuliah semester aktif',
            'data' => $jadwal
        ]);
    }

    // Membuat jadwal
    public function createJadwal(Request $request)
    {
        $validated = $request->validate([
            'mata_kuliah_id' => 'required|exists:mata_kuliahs,id',
            'dosen_id'       => 'required|exists:users,id',
            'semester_id'    => 'required|exists:semesters,id',
            'ruangan_id'     => 'required|exists:ruangans,id',
            'hari'           => 'required|string',
            'jam_mulai'      => 'required|date_format:H:i',
            'jam_selesai'    => 'required|date_format:H:i',
            'kuota'          => 'required|numeric',
        ]);

        if ($validated['jam_mulai'] >= $validated['jam_selesai']) {
            return response()->json([
                'status' => 'error',
                'message' => 'Waktu mulai harus sebelum waktu selesai'
            ], 400);
        }

        try {
            $jadwal = Jadwal::create($validated);
            return response()->json([
                'status' => 'success',
                'message' => 'Jadwal berhasil ditambahkan',
                'data' => $jadwal
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // Update Jadwal
    public function updateJadwal(Request $request, $id)
    {
        $jadwal = Jadwal::find($id);
        if (!$jadwal) {
            return response()->json([
                'status' => 'error',
                'message' => 'Jadwal tidak ditemukan'
            ], 404);
        }

        $validated = $request->validate([
            'mata_kuliah_id' => 'required|exists:mata_kuliahs,id',
            'dosen_id'       => 'required|exists:users,id',
            'semester_id'    => 'required|exists:semesters,id',
            'ruangan_id'     => 'required|exists:ruangans,id',
            'hari'           => 'required|string',
            'jam_mulai'      => 'required|date_format:H:i',
            'jam_selesai'    => 'required|date_format:H:i',
            'kuota'          => 'required|numeric',
        ]);

        if ($validated['jam_mulai'] >= $validated['jam_selesai']) {
            return response()->json([
                'status' => 'error',
                'message' => 'Waktu mulai harus sebelum waktu selesai'
            ], 400);
        }

        try {
            $jadwal->update($validated);
            return response()->json([
                'status' => 'success',
                'message' => 'Jadwal berhasil diperbarui',
                'data' => $jadwal
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // Hapus jadwal
    public function deleteJadwal($id)
    {
        try {
            $jadwal = Jadwal::find($id);
            if (!$jadwal) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Jadwal tidak ditemukan'
                ], 404);
            }
            $jadwal->delete();
            return response()->json([
                'status' => 'success',
                'message' => 'Jadwal berhasil dihapus'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
