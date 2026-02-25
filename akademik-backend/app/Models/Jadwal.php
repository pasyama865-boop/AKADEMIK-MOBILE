<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Support\Facades\Mail;

class Jadwal extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'jadwals';
    protected $fillable = [
        'mata_kuliah_id',
        'dosen_id',
        'semester_id',
        'kuota',
        'hari',
        'ruangan_id',
        'jam_mulai',
        'jam_selesai',
    ];

    // Relasi
    // Satu jadwal milik satu matakuliah
    public function mataKuliah()
    {
        return $this->belongsTo(MataKuliah::class, 'mata_kuliah_id');
    }

    // Satu jadwal milik satu ruangan
    public function ruangan()
    {
        return $this->belongsTo(Ruangan::class, 'ruangan_id');
    }
    // Satu jadwal milik satu dosen
    public function dosen()
    {
        return $this->belongsTo(User::class, 'dosen_id');
    }
    // Satu jadwal milik satu semester
    public function semester()
    {
        return $this->belongsTo(Semester::class, 'semester_id');
    }
}
