<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('krs', function (Blueprint $table) {
            if (DB::getDriverName() !== 'sqlite') {
                $table->dropForeign('krs_mahasiswa_id_foreign');
            }
            $table->foreign('mahasiswa_id')
                ->references('id')->on('mahasiswas')
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('krs', function (Blueprint $table) {
            if (DB::getDriverName() !== 'sqlite') {
                $table->dropForeign('krs_mahasiswa_id_foreign');
            }
            $table->foreign('mahasiswa_id')
                ->references('id')->on('users')
                ->cascadeOnDelete();
        });
    }
};
