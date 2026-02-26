<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * Model User.
 * Merepresentasikan akun pengguna yang bisa memiliki role:
 * admin, dosen, atau mahasiswa.
 */
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasUuids;

    /**
     * Atribut yang boleh diisi secara massal.
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'nim_nip',
    ];

    /**
     * Nilai default untuk atribut.
     */
    protected $attributes = [
        'role' => 'admin',
    ];

    /**
     * Atribut yang disembunyikan saat serialisasi (JSON).
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Konversi tipe data atribut.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    /**
     * Relasi: Satu user bisa memiliki satu profil dosen.
     */
    public function dosen()
    {
        return $this->hasOne(Dosen::class);
    }

    /**
     * Relasi: Satu user bisa memiliki satu profil mahasiswa.
     */
    public function mahasiswa()
    {
        return $this->hasOne(Mahasiswa::class);
    }
}
