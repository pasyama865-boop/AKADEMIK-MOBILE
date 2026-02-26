<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use Illuminate\Http\Request;

/**
 * Controller untuk mengelola data jadwal kuliah.
 * Menyediakan operasi CRUD lengkap untuk jadwal.
 */
class JadwalController extends Controller
{
    /**
     * Aturan validasi yang digunakan untuk create dan update jadwal.
     * Didefinisikan sebagai konstanta agar tidak duplikasi.
     */
    private const ATURAN_VALIDASI = [
        'mata_kuliah_id' => 'required|exists:mata_kuliahs,id',
        'dosen_id'       => 'required|exists:users,id',
        'semester_id'    => 'required|exists:semesters,id',
        'ruangan_id'     => 'required|exists:ruangans,id',
        'hari'           => 'required|string',
        'jam_mulai'      => 'required|date_format:H:i',
        'jam_selesai'    => 'required|date_format:H:i',
        'kuota'          => 'required|numeric',
    ];

    /**
     * Mengambil seluruh jadwal beserta relasi terkait.
     * Data diurutkan berdasarkan yang terbaru.
     */
    public function getJadwalList()
    {
        $daftarJadwal = Jadwal::with([
            'mataKuliah',
            'dosen',
            'semester',
            'ruangan',
        ])->latest()->get();

        return response()->json([
            'message' => 'Jadwal kuliah semester aktif',
            'data'    => $daftarJadwal,
        ]);
    }

    /**
     * Membuat jadwal kuliah baru.
     * Memvalidasi bahwa jam mulai harus sebelum jam selesai.
     */
    public function createJadwal(Request $request)
    {
        $dataValid = $request->validate(self::ATURAN_VALIDASI);

        // Pastikan jam mulai sebelum jam selesai
        if ($dataValid['jam_mulai'] >= $dataValid['jam_selesai']) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Waktu mulai harus sebelum waktu selesai',
            ], 400);
        }

        try {
            $jadwalBaru = Jadwal::create($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Jadwal berhasil ditambahkan',
                'data'    => $jadwalBaru,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Memperbarui data jadwal kuliah berdasarkan ID.
     * Memvalidasi bahwa jam mulai harus sebelum jam selesai.
     */
    public function updateJadwal(Request $request, $id)
    {
        $jadwal = Jadwal::find($id);

        if (!$jadwal) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Jadwal tidak ditemukan',
            ], 404);
        }

        $dataValid = $request->validate(self::ATURAN_VALIDASI);

        // Pastikan jam mulai sebelum jam selesai
        if ($dataValid['jam_mulai'] >= $dataValid['jam_selesai']) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Waktu mulai harus sebelum waktu selesai',
            ], 400);
        }

        try {
            $jadwal->update($dataValid);

            return response()->json([
                'status'  => 'success',
                'message' => 'Jadwal berhasil diperbarui',
                'data'    => $jadwal,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus jadwal kuliah berdasarkan ID.
     */
    public function deleteJadwal($id)
    {
        $jadwal = Jadwal::find($id);

        if (!$jadwal) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Jadwal tidak ditemukan',
            ], 404);
        }

        try {
            $jadwal->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Jadwal berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
