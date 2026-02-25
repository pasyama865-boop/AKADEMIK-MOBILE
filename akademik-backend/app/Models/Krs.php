<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Krs extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'krs';

    protected $fillable = [
        'mahasiswa_id', 'jadwal_id', 'status', 'nilai_akhir'
    ];

    // Relasi ke Jadwal
    public function jadwal()
    {
        return $this->belongsTo(Jadwal::class, 'jadwal_id');
    }

    // Relasi ke User Mahasiswa
    public function mahasiswa()
{
    return $this->belongsTo(Mahasiswa::class, 'mahasiswa_id');
}
}
