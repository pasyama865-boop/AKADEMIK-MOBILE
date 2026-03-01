<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * Model Mata Kuliah.
 * Merepresentasikan data mata kuliah yang tersedia di program studi.
 */
class MataKuliah extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $table = 'mata_kuliahs';

    protected $fillable = [
        'kode_matkul',
        'nama_matkul',
        'sks',
        'semester_paket',
        'deskripsi',
    ];
}
