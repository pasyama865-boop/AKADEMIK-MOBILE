<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Model Ruangan.
 * Merepresentasikan data ruangan yang digunakan untuk perkuliahan.
 */
class Ruangan extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'nama',
        'gedung',
        'kapasitas',
    ];

    /**
     * Relasi: Satu ruangan bisa memiliki banyak jadwal.
     */
    public function jadwal()
    {
        return $this->hasMany(Jadwal::class);
    }
}
