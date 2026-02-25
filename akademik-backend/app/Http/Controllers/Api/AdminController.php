<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;



class AdminController extends Controller
{
    // Mengambil semua data user admin
    public function getUserList()
    {
        $users = User::where('role', 'admin')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $users,
        ]);
    }

    public function createUser(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'admin',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'User berhasil ditambahkan',
            'data' => $user,
        ], 201);
    }

    public function updateUser(Request $request, $id)
    {
        $user = User::where('role', 'admin')->find($id);
        if (!$user) return response()->json(['message' => 'Admin tidak ditemukan'], 404);

        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $id,
            'password' => 'nullable|string|min:6',
        ]);

        try {
            $user->name = $request->name;
            $user->email = $request->email;

            if ($request->filled('password')) {
                $user->password = Hash::make($request->password);
            }

            $user->save();

            return response()->json(['status' => 'success', 'message' => 'Admin berhasil diperbarui', 'data' => $user]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function deleteUser($id)
    {
        // Pastikan hanya bisa menghapus role admin
        $user = User::where('role', 'admin')->find($id);
        if (!$user) return response()->json(['message' => 'Admin tidak ditemukan'], 404);

        try {
            $user->delete();
            return response()->json(['status' => 'success', 'message' => 'Admin berhasil dihapus']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal menghapus Admin.'], 500);
        }
    }
}
