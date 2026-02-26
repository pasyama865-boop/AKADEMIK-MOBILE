<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dosen;

/**
 * Controller untuk mengambil data dosen.
 * Operasi CRUD dosen berada di DataMasterController.
 */
class DosenController extends Controller
{
    /**
     * Mengambil seluruh daftar dosen beserta data user terkait.
     */
    public function getDosenList()
    {
        $daftarDosen = Dosen::with('user')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $daftarDosen,
        ]);
    }
}
