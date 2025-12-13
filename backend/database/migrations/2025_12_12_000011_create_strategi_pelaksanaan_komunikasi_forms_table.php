<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('strategi_pelaksanaan_komunikasi_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');

            // A. Proses Keperawatan
            $table->text('kondisi_klien')->nullable();
            $table->unsignedBigInteger('diagnosa_keperawatan')->nullable();
            $table->text('tujuan')->nullable();
            $table->json('tindakan_keperawatan')->nullable(); // Array of intervention IDs

            // B. Strategi Komunikasi - 1. Fase Orientasi
            $table->text('salam_terapeutik')->nullable();
            $table->text('evaluasi_validasi')->nullable();
            $table->text('kontrak_orientasi')->nullable();
            $table->text('menjaga_kerahasiaan')->nullable();

            // 2. Fase Kerja
            $table->text('fase_kerja')->nullable();

            // 3. Fase Terminasi
            $table->text('evaluasi_subjektif')->nullable();
            $table->text('evaluasi_objektif')->nullable();
            $table->text('rencana_tindak_lanjut')->nullable();
            $table->text('kontrak_terminasi')->nullable();

            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('strategi_pelaksanaan_komunikasi_forms');
    }
};
