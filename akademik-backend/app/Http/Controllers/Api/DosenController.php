<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use Illuminate\Http\Request;

class DosenController extends Controller
{
    // Mengambil semua data dari tabel dosen
    public function getDosenList()
    {
        $dosen = Dosen::with('user')->get();

        return response()->json([
            'status' => 'success',
            'data' => $dosen,
        ]);
    }
}
