<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Model Mahasiswa.
 * Merepresentasikan data profil mahasiswa yang terhubung ke akun user.
 */
class Mahasiswa extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'nim',
        'jurusan',
        'angkatan',
    ];

    /**
     * Relasi: Setiap mahasiswa memiliki satu akun user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
