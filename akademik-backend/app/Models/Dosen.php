<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Model Dosen.
 * Merepresentasikan data profil dosen yang terhubung ke akun user.
 */
class Dosen extends Model
{
    use HasFactory, HasUuids;

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
}
