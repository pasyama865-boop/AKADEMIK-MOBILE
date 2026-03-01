<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * Model Dosen.
 * Merepresentasikan data profil dosen yang terhubung ke akun user.
 */
class Dosen extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'nip',
        'gelar',
        'no_hp',
    ];

    /**
     * Relasi: Setiap dosen memiliki satu akun user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: Dosen dapat memiliki banyak mahasiswa bimbingan (sebagai Dosen Wali).
     */
    public function mahasiswas()
    {
        return $this->hasMany(Mahasiswa::class, 'dosen_id');
    }
}
