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
        Schema::table('jadwals', function (Blueprint $table) {
            $table->index('hari');
            $table->index(['jam_mulai', 'jam_selesai']);
        });

        Schema::table('krs', function (Blueprint $table) {
            $table->index(['mahasiswa_id', 'jadwal_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('jadwals', function (Blueprint $table) {
            $table->dropIndex(['hari']);
            $table->dropIndex(['jam_mulai', 'jam_selesai']);
        });

        Schema::table('krs', function (Blueprint $table) {
            $table->dropIndex(['mahasiswa_id', 'jadwal_id']);
        });
    }
};
