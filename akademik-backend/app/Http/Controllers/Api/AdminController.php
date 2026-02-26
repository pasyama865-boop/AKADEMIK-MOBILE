<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

/**
 * Controller untuk mengelola data user admin.
 * Menyediakan operasi CRUD khusus untuk user dengan role 'admin'.
 */
class AdminController extends Controller
{
    /**
     * Mengambil seluruh daftar user admin.
     * Data diurutkan berdasarkan tanggal pembuatan terbaru.
     */
    public function getUserList()
    {
        $daftarAdmin = User::where('role', 'admin')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $daftarAdmin,
        ]);
    }

    /**
     * Membuat user admin baru.
     * Password akan di-hash sebelum disimpan ke database.
     */
    public function createUser(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        $adminBaru = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => 'admin',
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'User berhasil ditambahkan',
            'data'    => $adminBaru,
        ], 201);
    }

    /**
     * Memperbarui data user admin berdasarkan ID.
     * Password hanya diperbarui jika diisi pada request.
     */
    public function updateUser(Request $request, $id)
    {
        // Cari admin berdasarkan ID, pastikan rolenya admin
        $admin = User::where('role', 'admin')->find($id);

        if (!$admin) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Admin tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users,email,' . $id,
            'password' => 'nullable|string|min:6',
        ]);

        try {
            $admin->name  = $request->name;
            $admin->email = $request->email;

            // Perbarui password hanya jika field diisi
            if ($request->filled('password')) {
                $admin->password = Hash::make($request->password);
            }

            $admin->save();

            return response()->json([
                'status'  => 'success',
                'message' => 'Admin berhasil diperbarui',
                'data'    => $admin,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menghapus user admin berdasarkan ID.
     * Hanya user dengan role 'admin' yang bisa dihapus melalui fungsi ini.
     */
    public function deleteUser($id)
    {
        // Pastikan hanya bisa menghapus user dengan role admin
        $admin = User::where('role', 'admin')->find($id);

        if (!$admin) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Admin tidak ditemukan',
            ], 404);
        }

        try {
            $admin->delete();

            return response()->json([
                'status'  => 'success',
                'message' => 'Admin berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal menghapus Admin.',
            ], 500);
        }
    }
}
