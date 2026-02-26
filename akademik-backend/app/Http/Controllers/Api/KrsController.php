<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Controller untuk mengelola data KRS (Kartu Rencana Studi).
 * Menyediakan operasi CRUD dengan validasi duplikat, kuota, dan bentrok jadwal.
 */
class KrsController extends Controller
{
    /**
     * Mengambil seluruh daftar KRS beserta relasi terkait.
     * Data diurutkan berdasarkan yang terbaru.
     */
    public function getKrsList()
    {
        $daftarKrs = Krs::with([
            'mahasiswa.user',
            'jadwal.dosen',
            'jadwal.mataKuliah',
            'jadwal.ruangan',
        ])->latest()->get();

        return response()->json([
            'message' => 'Data KRS berhasil diambil',
            'data'    => $daftarKrs,
        ]);
    }

    /**
     * Membuat KRS baru (oleh Admin).
     *
     * Dilengkapi 3 tahap validasi:
     * 1. Cek duplikat - apakah mahasiswa sudah mengambil jadwal ini
     * 2. Cek kuota   - apakah kelas masih tersedia
     * 3. Cek bentrok - apakah ada jadwal lain yang waktunya bertabrakan
     */
    public function createKrs(Request $request)
    {
        $request->validate([
            'mahasiswa_id' => 'required',
            'jadwal_id'    => 'required|exists:jadwals,id',
        ]);

        $mahasiswaId = $request->mahasiswa_id;
        $jadwalBaru  = Jadwal::with('mataKuliah', 'semester')->findOrFail($request->jadwal_id);

        // Validasi 1: Cek duplikat pengambilan jadwal
        $sudahMengambil = Krs::where('mahasiswa_id', $mahasiswaId)
            ->where('jadwal_id', $jadwalBaru->id)
            ->exists();

        if ($sudahMengambil) {
            return response()->json([
                'message' => 'Mahasiswa ini sudah mengambil jadwal tersebut.',
            ], 400);
        }

        // Validasi 2: Cek ketersediaan kuota kelas
        $jumlahPeserta = Krs::where('jadwal_id', $jadwalBaru->id)->count();

        if ($jumlahPeserta >= $jadwalBaru->kuota) {
            return response()->json([
                'message' => 'Kelas Penuh! Kuota sudah habis.',
            ], 400);
        }

        // Validasi 3: Cek bentrok jadwal di hari dan semester yang sama
        $errorBentrok = $this->cekBentrokJadwal($mahasiswaId, $jadwalBaru);

        if ($errorBentrok) {
            return $errorBentrok;
        }

        // Simpan KRS baru dalam transaction
        $krsBaru = DB::transaction(function () use ($mahasiswaId, $jadwalBaru) {
            return Krs::create([
                'mahasiswa_id' => $mahasiswaId,
                'jadwal_id'    => $jadwalBaru->id,
                'status'       => 'approved',
            ]);
        });

        return response()->json([
            'message' => 'Berhasil mendaftarkan mata kuliah untuk mahasiswa',
            'data'    => $krsBaru,
        ], 201);
    }

    /**
     * Memperbarui data KRS berdasarkan ID.
     *
     * Validasi sama seperti createKrs, namun mengecualikan
     * data KRS yang sedang diedit dari pengecekan duplikat dan bentrok.
     */
    public function updateKrs(Request $request, $id)
    {
        $krs = Krs::find($id);

        if (!$krs) {
            return response()->json([
                'message' => 'Data KRS tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'mahasiswa_id' => 'required',
            'jadwal_id'    => 'required|exists:jadwals,id',
        ]);

        $mahasiswaId = $request->mahasiswa_id;
        $jadwalBaru  = Jadwal::with('mataKuliah', 'semester')->findOrFail($request->jadwal_id);

        // Validasi 1: Cek duplikat (kecuali KRS yang sedang diedit)
        $sudahMengambil = Krs::where('mahasiswa_id', $mahasiswaId)
            ->where('jadwal_id', $jadwalBaru->id)
            ->where('id', '!=', $id)
            ->exists();

        if ($sudahMengambil) {
            return response()->json([
                'message' => 'Mahasiswa ini sudah mengambil jadwal tersebut.',
            ], 400);
        }

        // Validasi 2: Cek kuota (hanya jika jadwal diganti ke jadwal lain)
        if ($krs->jadwal_id != $jadwalBaru->id) {
            $jumlahPeserta = Krs::where('jadwal_id', $jadwalBaru->id)->count();

            if ($jumlahPeserta >= $jadwalBaru->kuota) {
                return response()->json([
                    'message' => 'Kelas Penuh! Kuota sudah habis.',
                ], 400);
            }
        }

        // Validasi 3: Cek bentrok jadwal (kecuali KRS yang sedang diedit)
        $errorBentrok = $this->cekBentrokJadwal($mahasiswaId, $jadwalBaru, $id);

        if ($errorBentrok) {
            return $errorBentrok;
        }

        // Eksekusi update KRS
        $krs->update([
            'mahasiswa_id' => $mahasiswaId,
            'jadwal_id'    => $jadwalBaru->id,
        ]);

        return response()->json([
            'message' => 'Berhasil memperbarui KRS mahasiswa',
            'data'    => $krs,
        ]);
    }

    /**
     * Menghapus data KRS berdasarkan ID.
     */
    public function deleteKrs($id)
    {
        $krs = Krs::find($id);

        if (!$krs) {
            return response()->json([
                'message' => 'Data tidak ditemukan',
            ], 404);
        }

        $krs->delete();

        return response()->json([
            'message' => 'Mata kuliah berhasil dibatalkan',
        ]);
    }

    // ============================================================
    // METHOD PRIVAT (HELPER)
    // ============================================================

    /**
     * Mengecek apakah ada bentrok jadwal untuk mahasiswa tertentu.
     *
     * Membandingkan jadwal baru dengan semua jadwal yang sudah diambil
     * mahasiswa di hari dan semester yang sama.
     *
     * @param  string      $mahasiswaId  ID mahasiswa yang dicek
     * @param  Jadwal      $jadwalBaru   Data jadwal yang akan diambil/diubah
     * @param  string|null $krsIdDikecualikan  ID KRS yang dikecualikan (untuk update)
     * @return \Illuminate\Http\JsonResponse|null  Respons error jika bentrok, null jika aman
     */
    private function cekBentrokJadwal(string $mahasiswaId, Jadwal $jadwalBaru, ?string $krsIdDikecualikan = null)
    {
        $queryKrsLainnya = Krs::with('jadwal')
            ->where('mahasiswa_id', $mahasiswaId)
            ->whereHas('jadwal', function ($query) use ($jadwalBaru) {
                $query->where('semester_id', $jadwalBaru->semester_id);
                $query->where('hari', $jadwalBaru->hari);
            });

        // Kecualikan KRS tertentu (digunakan saat proses update)
        if ($krsIdDikecualikan) {
            $queryKrsLainnya->where('id', '!=', $krsIdDikecualikan);
        }

        $daftarKrsLainnya = $queryKrsLainnya->get();

        foreach ($daftarKrsLainnya as $krsLain) {
            $jadwalLama = $krsLain->jadwal;

            // Cek tumpang tindih waktu: jadwal baru mulai sebelum lama selesai DAN lama mulai sebelum baru selesai
            $isBentrok = $jadwalBaru->jam_mulai < $jadwalLama->jam_selesai
                && $jadwalLama->jam_mulai < $jadwalBaru->jam_selesai;

            if ($isBentrok) {
                $namaMatkul = $jadwalLama->mataKuliah->nama_matkul ?? 'Tidak diketahui';

                return response()->json([
                    'message' => 'Jadwal Bentrok!',
                    'detail'  => "Mahasiswa ini sudah ada kelas: {$namaMatkul}",
                ], 400);
            }
        }

        return null;
    }
}
