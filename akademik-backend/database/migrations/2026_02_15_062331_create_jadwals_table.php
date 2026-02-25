<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('jadwals', function (Blueprint $table) {
            $table->uuid('id')->primary();
            // Relasi foreign key
            // Menghubungkan ke tabel mata_kuliahs
            $table->foreignUuId('mata_kuliah_id')->constrained('mata_kuliahs')->onDelete('cascade');
            // Menghubungkan ke tabel ruangans
            $table->foreignUuid('ruangan_id')->constrained('ruangans')->onDelete('restrict');
            // Menghubungkan ke tabel users (khusus dosen)
            $table->foreignUuid('dosen_id')->constrained('users')->onDelete('cascade');
            // Menghubungkan ke tabel semesters
            $table->foreignUuid('semester_id')->constrained('semesters')->onDelete('cascade');
            // Data operasional
            $table->string('hari');
            $table->time('jam_mulai');
            $table->time('jam_selesai');
            $table->integer('kuota');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jadwals');
    }
};
