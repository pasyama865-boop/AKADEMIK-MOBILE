<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Model Jadwal.
 * Merepresentasikan jadwal kuliah yang menghubungkan
 * mata kuliah, dosen, ruangan, dan semester.
 */
class Jadwal extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'jadwals';

    protected $fillable = [
        'mata_kuliah_id',
        'dosen_id',
        'semester_id',
        'ruangan_id',
        'hari',
        'jam_mulai',
        'jam_selesai',
        'kuota',
    ];

    /**
     * Relasi: Satu jadwal dimiliki oleh satu mata kuliah.
     */
    public function mataKuliah()
    {
        return $this->belongsTo(MataKuliah::class, 'mata_kuliah_id');
    }

    /**
     * Relasi: Satu jadwal dimiliki oleh satu ruangan.
     */
    public function ruangan()
    {
        return $this->belongsTo(Ruangan::class, 'ruangan_id');
    }

    /**
     * Relasi: Satu jadwal dimiliki oleh satu dosen (via tabel users).
     */
    public function dosen()
    {
        return $this->belongsTo(User::class, 'dosen_id');
    }

    /**
     * Relasi: Satu jadwal dimiliki oleh satu semester.
     */
    public function semester()
    {
        return $this->belongsTo(Semester::class, 'semester_id');
    }
}
