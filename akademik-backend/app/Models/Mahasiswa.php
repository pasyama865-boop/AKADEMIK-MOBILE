<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * Model Mahasiswa.
 * Merepresentasikan data profil mahasiswa yang terhubung ke akun user.
 */
class Mahasiswa extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'dosen_id',
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

    /**
     * Relasi: Mahasiswa bisa memiliki satu dosen pembimbing akademik (Dosen Wali).
     */
    public function dosenWali()
    {
        return $this->belongsTo(Dosen::class, 'dosen_id');
    }
}
