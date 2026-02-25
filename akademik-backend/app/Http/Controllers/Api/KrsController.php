<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KrsController extends Controller
{
    // 1. GET LIST KRS
    public function getKrsList()
    {
        $krs = Krs::with([
            'mahasiswa.user',
            'jadwal.dosen',
            'jadwal.mataKuliah',
            'jadwal.ruangan'
        ])->latest()->get();

        return response()->json([
            'message' => 'Data KRS berhasil diambil',
            'data' => $krs,
        ]);
    }

    // 2. CREATE KRS OLEH ADMIN
    public function createKrs(Request $request)
    {
        $request->validate([
            'mahasiswa_id' => 'required',
            'jadwal_id'    => 'required|exists:jadwals,id'
        ]);

        $mahasiswaId = $request->mahasiswa_id;
        $jadwalBaru = Jadwal::with('mataKuliah', 'semester')->findOrFail($request->jadwal_id);

        // VALIDASI 1: CEK DUPLIKAT
        $sudahAmbil = Krs::where('mahasiswa_id', $mahasiswaId)
            ->where('jadwal_id', $jadwalBaru->id)
            ->exists();

        if ($sudahAmbil) {
            return response()->json(['message' => 'Mahasiswa ini sudah mengambil jadwal tersebut.'], 400);
        }

        // VALIDASI 2 : CEK KUOTA
        $peserta = Krs::where('jadwal_id', $jadwalBaru->id)->count();
        if ($peserta >= $jadwalBaru->kuota) {
            return response()->json(['message' => 'Kelas Penuh! Kuota sudah habis.'], 400);
        }

        // VALIDASI 3: CEK BENTROK JAM
        $krsSayaLainnya = Krs::with('jadwal')
            ->where('mahasiswa_id', $mahasiswaId)
            ->whereHas('jadwal', function($q) use ($jadwalBaru) {
                $q->where('semester_id', $jadwalBaru->semester_id);
                $q->where('hari', $jadwalBaru->hari);
            })
            ->get();

        foreach ($krsSayaLainnya as $krs) {
            $jadwalLama = $krs->jadwal;

            if ($jadwalBaru->jam_mulai < $jadwalLama->jam_selesai &&
                $jadwalLama->jam_mulai < $jadwalBaru->jam_selesai) {

                return response()->json([
                    'message' => 'Jadwal Bentrok!',
                    'detail' => "Mahasiswa ini sudah ada kelas: " . ($jadwalLama->mataKuliah->nama_matkul ?? 'Tidak diketahui')
                ], 400);
            }
        }

        // EKSEKUSI SIMPAN
        $krsBaru = DB::transaction(function () use ($mahasiswaId, $jadwalBaru) {
            return Krs::create([
                'mahasiswa_id' => $mahasiswaId,
                'jadwal_id'    => $jadwalBaru->id,
                'status'       => 'approved'
            ]);
        });

        return response()->json([
            'message' => 'Berhasil mendaftarkan mata kuliah untuk mahasiswa',
            'data' => $krsBaru
        ], 201);
    }

    // Update KRS
    // 4. UPDATE KRS (Edit)
    public function updateKrs(Request $request, $id)
    {
        $krs = Krs::find($id);
        if (!$krs) {
            return response()->json(['message' => 'Data KRS tidak ditemukan'], 404);
        }

        $request->validate([
            'mahasiswa_id' => 'required',
            'jadwal_id'    => 'required|exists:jadwals,id'
        ]);

        $mahasiswaId = $request->mahasiswa_id;
        $jadwalBaru = Jadwal::with('mataKuliah', 'semester')->findOrFail($request->jadwal_id);

        // VALIDASI 1: CEK DUPLIKAT (Kecuali KRS ini sendiri)
        $sudahAmbil = Krs::where('mahasiswa_id', $mahasiswaId)
            ->where('jadwal_id', $jadwalBaru->id)
            ->where('id', '!=', $id) // Pengecualian
            ->exists();

        if ($sudahAmbil) {
            return response()->json(['message' => 'Mahasiswa ini sudah mengambil jadwal tersebut.'], 400);
        }

        // VALIDASI 2 : CEK KUOTA (Hanya jika jadwalnya diganti ke jadwal lain)
        if ($krs->jadwal_id != $jadwalBaru->id) {
            $peserta = Krs::where('jadwal_id', $jadwalBaru->id)->count();
            if ($peserta >= $jadwalBaru->kuota) {
                return response()->json(['message' => 'Kelas Penuh! Kuota sudah habis.'], 400);
            }
        }

        // VALIDASI 3: CEK BENTROK JAM (Kecuali KRS ini sendiri)
        $krsSayaLainnya = Krs::with('jadwal')
            ->where('mahasiswa_id', $mahasiswaId)
            ->where('id', '!=', $id) // Pengecualian data lama
            ->whereHas('jadwal', function($q) use ($jadwalBaru) {
                $q->where('semester_id', $jadwalBaru->semester_id);
                $q->where('hari', $jadwalBaru->hari);
            })
            ->get();

        foreach ($krsSayaLainnya as $krsLain) {
            $jadwalLama = $krsLain->jadwal;

            if ($jadwalBaru->jam_mulai < $jadwalLama->jam_selesai &&
                $jadwalLama->jam_mulai < $jadwalBaru->jam_selesai) {

                return response()->json([
                    'message' => 'Jadwal Bentrok!',
                    'detail' => "Mahasiswa ini sudah ada kelas: " . ($jadwalLama->mataKuliah->nama_matkul ?? 'Tidak diketahui')
                ], 400);
            }
        }

        // EKSEKUSI UPDATE
        $krs->update([
            'mahasiswa_id' => $mahasiswaId,
            'jadwal_id'    => $jadwalBaru->id,
        ]);

        return response()->json([
            'message' => 'Berhasil memperbarui KRS mahasiswa',
            'data' => $krs
        ]);
    }


    // 3. DELETE KRS
    public function deleteKrs($id)
    {
        $krs = Krs::find($id);
        if (!$krs) {
            return response()->json(['message' => 'Data tidak ditemukan'], 404);
        }
        $krs->delete();
        return response()->json(['message' => 'Mata kuliah berhasil dibatalkan']);
    }
}
