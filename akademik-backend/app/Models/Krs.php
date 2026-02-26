<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Model KRS (Kartu Rencana Studi).
 * Merepresentasikan pengambilan jadwal kuliah oleh mahasiswa.
 */
class Krs extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'krs';

    protected $fillable = [
        'mahasiswa_id',
        'jadwal_id',
        'status',
        'nilai_akhir',
    ];

    /**
     * Relasi: Satu KRS dimiliki oleh satu jadwal.
     */
    public function jadwal()
    {
        return $this->belongsTo(Jadwal::class, 'jadwal_id');
    }

    /**
     * Relasi: Satu KRS dimiliki oleh satu mahasiswa.
     */
    public function mahasiswa()
    {
        return $this->belongsTo(Mahasiswa::class, 'mahasiswa_id');
    }
}
