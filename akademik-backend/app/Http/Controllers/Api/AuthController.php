<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Controller untuk menangani proses autentikasi pengguna.
 * Meliputi fungsi login dan logout menggunakan Laravel Sanctum.
 */
class AuthController extends Controller
{
    /**
     * Proses login pengguna.
     *
     * Memvalidasi email dan password, lalu mengembalikan token akses
     * beserta data user (termasuk relasi dosen/mahasiswa) jika berhasil.
     */
    public function login(Request $request)
    {
        // Validasi input dari pengguna
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        // Cari user berdasarkan email
        $user = User::where('email', $request->email)->first();

        // Periksa apakah user ditemukan dan password cocok
        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Login gagal. Pastikan email dan password benar.'],
            ]);
        }

        // Muat relasi dosen dan mahasiswa untuk data lengkap
        $user->load(['dosen', 'mahasiswa']);

        // Buat token autentikasi baru
        $token = $user->createToken('auth_token')->plainTextToken;

        // Kirim respons login berhasil
        return response()->json([
            'message'      => 'Login berhasil',
            'access_token' => $token,
            'token_type'   => 'Bearer',
            'user'         => $user,
        ]);
    }

    /**
     * Proses logout pengguna.
     *
     * Menghapus token akses yang sedang digunakan saat ini.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * Memperbarui token akses (Refresh Token).
     *
     * Menghapus token yang lama dan mengeluarkan token yang baru
     * untuk memperpanjang sesi pengguna.
     */
    public function refresh(Request $request)
    {
        $user = $request->user();
        
        // Hapus token akses yang sedang digunakan
        $user->currentAccessToken()->delete();

        // Buat token baru dengan waktu kedaluwarsa baru (24 jam)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message'      => 'Token berhasil diperbarui',
            'access_token' => $token,
            'token_type'   => 'Bearer',
        ]);
    }
}
