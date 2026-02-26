<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DataMasterController;
use App\Http\Controllers\Api\DosenController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\KrsController;
use App\Http\Controllers\Api\MahasiswaController;
use App\Http\Controllers\Api\MataKuliahController;
use App\Http\Controllers\Api\RuanganController;
use App\Http\Controllers\Api\SemesterController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// ROUTE PUBLIK (Tanpa Autentikasi)
Route::post('/login', [AuthController::class, 'login']);

// ROUTE TERLINDUNGI (Wajib Login / Token Sanctum)
Route::middleware('auth:sanctum')->group(function () {

    // Autentikasi & Profil (semua role boleh akses)
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', function (Request $request) {
        return $request->user();
    });

    // ============================================================
    // ROUTE KHUSUS ADMIN (hanya role 'admin' yang boleh akses)
    // ============================================================
    Route::middleware('role:admin')->prefix('admin')->group(function () {

        // Dashboard Admin - Statistik
        Route::get('stats', [DataMasterController::class, 'getAdminStats']);

        // CRUD Admin Users
        Route::get('users', [AdminController::class, 'getUserList']);
        Route::post('users', [AdminController::class, 'createUser']);
        Route::put('users/{id}', [AdminController::class, 'updateUser']);
        Route::delete('users/{id}', [AdminController::class, 'deleteUser']);

        // CRUD Dosen
        Route::get('dosen', [DosenController::class, 'getDosenList']);
        Route::post('dosen', [DataMasterController::class, 'createDosen']);
        Route::put('dosen/{id}', [DataMasterController::class, 'updateDosen']);
        Route::delete('dosen/{id}', [DataMasterController::class, 'deleteDosen']);

        // CRUD Mahasiswa
        Route::get('mahasiswa', [MahasiswaController::class, 'getMahasiswaList']);
        Route::post('mahasiswa', [MahasiswaController::class, 'createMahasiswa']);
        Route::put('mahasiswa/{id}', [MahasiswaController::class, 'updateMahasiswa']);
        Route::delete('mahasiswa/{id}', [MahasiswaController::class, 'deleteMahasiswa']);

        // CRUD Mata Kuliah
        Route::get('matakuliah', [MataKuliahController::class, 'getMataKuliahList']);
        Route::post('matakuliah', [MataKuliahController::class, 'createMataKuliah']);
        Route::put('matakuliah/{id}', [MataKuliahController::class, 'updateMataKuliah']);
        Route::delete('matakuliah/{id}', [MataKuliahController::class, 'deleteMataKuliah']);

        // CRUD Jadwal
        Route::get('jadwal', [JadwalController::class, 'getJadwalList']);
        Route::post('jadwal', [JadwalController::class, 'createJadwal']);
        Route::put('jadwal/{id}', [JadwalController::class, 'updateJadwal']);
        Route::delete('jadwal/{id}', [JadwalController::class, 'deleteJadwal']);

        // CRUD KRS (Admin)
        Route::get('krs', [KrsController::class, 'getKrsList']);
        Route::post('krs', [KrsController::class, 'createKrs']);
        Route::put('krs/{id}', [KrsController::class, 'updateKrs']);
        Route::delete('krs/{id}', [KrsController::class, 'deleteKrs']);

        // CRUD Ruangan
        Route::get('ruangan', [RuanganController::class, 'getRuanganList']);
        Route::post('ruangan', [RuanganController::class, 'createRuangan']);
        Route::put('ruangan/{id}', [RuanganController::class, 'updateRuangan']);
        Route::delete('ruangan/{id}', [RuanganController::class, 'deleteRuangan']);

        // CRUD Semester
        Route::get('semester', [SemesterController::class, 'getSemesterList']);
        Route::post('semester', [SemesterController::class, 'createSemester']);
        Route::put('semester/{id}', [SemesterController::class, 'updateSemester']);
        Route::delete('semester/{id}', [SemesterController::class, 'deleteSemester']);
    });

    // ============================================================
    // ROUTE UMUM (semua role yang sudah login boleh akses)
    // ============================================================

    // Data Master (Dropdown / Referensi)
    Route::get('/mata-kuliah', [DataMasterController::class, 'getMataKuliah']);
    Route::get('/ruangan', [DataMasterController::class, 'getRuangan']);
    Route::get('/semesters', [DataMasterController::class, 'getSemesters']);

    // Jadwal & KRS Mahasiswa
    Route::get('/jadwal', [JadwalController::class, 'index']);
    Route::get('/krs', [KrsController::class, 'index']);
    Route::post('/krs', [KrsController::class, 'store']);
    Route::delete('/krs/{id}', [KrsController::class, 'destroy']);
});
