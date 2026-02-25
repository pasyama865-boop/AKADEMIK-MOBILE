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
        Schema::table('krs', function (Blueprint $table) {
            $table->dropForeign('krs_mahasiswa_id_foreign');
            $table->foreignUuid('mahasiswa_id')
                ->constrained('mahasiswas')
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('krs', function (Blueprint $table) {
            $table->dropForeign(['mahasiswa_id']);
            $table->foreignUuid('mahasiswa_id')
                ->constrained('users');
        });
    }
};
