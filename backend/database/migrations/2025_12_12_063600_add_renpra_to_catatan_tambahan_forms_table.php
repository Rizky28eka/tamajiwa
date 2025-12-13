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
        Schema::table('catatan_tambahan_forms', function (Blueprint $table) {
            // Add JSON column for Rencana Perawatan (Renpra)
            $table->json('renpra')->nullable()->after('tindak_lanjut')
                ->comment('Rencana Perawatan (diagnosis, intervensi, tujuan, kriteria, rasional)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('catatan_tambahan_forms', function (Blueprint $table) {
            $table->dropColumn('renpra');
        });
    }
};
