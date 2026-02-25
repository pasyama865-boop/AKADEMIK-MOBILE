<?php

use App\Http\Controllers\Api\AdminController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DataMasterController;
use App\Http\Controllers\Api\DosenController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\KrsController;
use App\Http\Controllers\Api\MahasiswaController;
use App\Http\Controllers\Api\MataKuliahController;
use App\Http\Controllers\Api\RuanganController;
use App\Http\Controllers\Api\SemesterController;

// LOGIN (Publik)
Route::post('/login', [AuthController::class, 'login']);

// AREA TERKUNCI Harus punya Token
Route::middleware('auth:sanctum')->group(function () {
    // Logout & Profile
    Route::get('admin/stats', [DataMasterController::class, 'getAdminStats']);
    Route::get('admin/dosen', [DosenController::class, 'getDosenList']);
    Route::get('admin/jadwal', [JadwalController::class, 'getJadwalList']);
    Route::get('admin/krs', [KrsController::class, 'getKrsList']);
    Route::get('admin/mahasiswa', [MahasiswaController::class, 'getMahasiswaList']);
    Route::get('admin/matakuliah', [MataKuliahController::class, 'getMataKuliahList']);
    Route::get('admin/ruangan', [RuanganController::class, 'getRuanganList']);
    Route::get('admin/semester', [SemesterController::class, 'getSemesterList']);
    Route::get('admin/users', [AdminController::class, 'getUserList']);
    Route::post('admin/users', [AdminController::class, 'createUser']);
    Route::put('admin/users/{id}', [AdminController::class, 'updateUser']);
    Route::delete('admin/users/{id}', [AdminController::class, 'deleteUser']);
    Route::post('/admin/dosen', [DataMasterController::class, 'createDosen']);
    Route::delete('/admin/dosen/{id}', [DataMasterController::class, 'deleteDosen']);
    Route::put('/admin/dosen/{id}', [DataMasterController::class, 'updateDosen']);
    Route::post('/admin/mahasiswa', [MahasiswaController::class, 'createMahasiswa']);
    Route::put('/admin/mahasiswa/{id}', [MahasiswaController::class, 'updateMahasiswa']);
    Route::delete('/admin/mahasiswa/{id}', [MahasiswaController::class, 'deleteMahasiswa']);
    Route::post('/admin/matakuliah', [MataKuliahController::class, 'createMataKuliah']);
    Route::put('/admin/matakuliah/{id}', [MataKuliahController::class, 'updateMataKuliah']);
    Route::delete('/admin/matakuliah/{id}', [MataKuliahController::class, 'deleteMataKuliah']);
    Route::post('/admin/jadwal', [JadwalController::class, 'createJadwal']);
    Route::put('/admin/jadwal/{id}', [JadwalController::class, 'updateJadwal']);
    Route::delete('/admin/jadwal/{id}', [JadwalController::class, 'deleteJadwal']);
    Route::post('/admin/krs', [KrsController::class, 'createKrs']);
    Route::delete('/admin/krs/{id}', [KrsController::class, 'deleteKrs']);
    Route::put('/admin/krs/{id}', [KrsController::class, 'updateKrs']);
    Route::post('/admin/ruangan', [RuanganController::class, 'createRuangan']);
    Route::put('/admin/ruangan/{id}', [RuanganController::class, 'updateRuangan']);
    Route::delete('/admin/ruangan/{id}', [RuanganController::class, 'deleteRuangan']);
    Route::post('/admin/semester', [SemesterController::class, 'createSemester']);
    Route::put('/admin/semester/{id}', [SemesterController::class, 'updateSemester']);
    Route::delete('/admin/semester/{id}', [SemesterController::class, 'deleteSemester']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', function (Request $request) {
        return $request->user();
    });

    // Data Master
    Route::get('/mata-kuliah', [DataMasterController::class, 'getMataKuliah']);
    Route::get('/ruangan', [DataMasterController::class, 'getRuangan']);
    Route::get('/semesters', [DataMasterController::class, 'getSemesters']);

    // Jadwal
    Route::get('/jadwal', [JadwalController::class, 'index']);
    Route::get('/krs', [KrsController::class, 'index']);
    Route::post('/krs', [KrsController::class, 'store']);
    Route::delete('/krs/{id}', [KrsController::class, 'destroy']);
});
