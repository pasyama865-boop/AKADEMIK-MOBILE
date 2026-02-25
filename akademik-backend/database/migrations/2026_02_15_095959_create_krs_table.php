<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('krs', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // Siapa yang ambil? (Mahasiswa)
            $table->foreignUuid('mahasiswa_id')
                  ->constrained('mahasiswas')
                  ->cascadeOnDelete();

            // Ambil jadwal yang mana?
            $table->foreignUuid('jadwal_id')
                  ->constrained('jadwals')
                  ->cascadeOnDelete();

            // Status pengajuan
            $table->string('status')->default('approved');

            // Nanti buat simpan nilai
            $table->string('nilai_akhir')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('krs');
    }
};
