<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class MataKuliah extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'mata_kuliahs';

    protected $fillable = [
        'kode_matkul', 'nama_matkul', 'sks', 'semester_paket', 'deskripsi'
    ];
}
