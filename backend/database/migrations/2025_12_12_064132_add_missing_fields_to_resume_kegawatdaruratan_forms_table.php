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
        Schema::table('resume_kegawatdaruratan_forms', function (Blueprint $table) {
            // Anamnesis - Extended (1 field)
            $table->text('faktor_pencetus')->nullable()->after('riwayat_pengobatan')
                ->comment('Faktor yang memicu kegawatdaruratan');

            // Pemeriksaan Fisik - Extended (3 fields)
            $table->text('keadaan_umum')->nullable()->after('riwayat_pengobatan')
                ->comment('Keadaan umum pasien');
            $table->text('tanda_vital')->nullable()->after('keadaan_umum')
                ->comment('Tanda vital lengkap');
            $table->text('pemeriksaan_lain')->nullable()->after('spo2')
                ->comment('Pemeriksaan fisik tambahan');

            // Status Mental - Extended (3 fields)
            $table->text('orientasi')->nullable()->after('kognitif')
                ->comment('Orientasi waktu, tempat, orang');
            $table->text('bentuk_pemikiran')->nullable()->after('orientasi')
                ->comment('Bentuk/struktur pemikiran');
            $table->text('isi_pemikiran')->nullable()->after('bentuk_pemikiran')
                ->comment('Isi pikiran pasien');

            // Diagnosis & Tindakan - Extended (4 fields)
            $table->text('diagnosis_banding')->nullable()->after('diagnosis_kerja')
                ->comment('Diagnosis banding/alternatif');
            $table->text('diagnosis_tambahan')->nullable()->after('diagnosis_banding')
                ->comment('Diagnosis tambahan');
            $table->text('tindakan_keperawatan')->nullable()->after('tindakan_yang_dilakukan')
                ->comment('Tindakan keperawatan yang dilakukan');
            $table->text('terapi_psikososial')->nullable()->after('tindakan_keperawatan')
                ->comment('Terapi psikososial yang diberikan');

            // Section 7: Implementasi (3 fields)
            $table->text('pelaksanaan_intervensi')->nullable()->after('terapi_obat')
                ->comment('Pelaksanaan intervensi keperawatan');
            $table->text('kolaborasi_tim')->nullable()->after('pelaksanaan_intervensi')
                ->comment('Kolaborasi dengan tim medis lain');
            $table->text('edukasi')->nullable()->after('kolaborasi_tim')
                ->comment('Edukasi yang diberikan kepada pasien/keluarga');

            // Section 8: Evaluasi (4 fields)
            $table->text('respon_intervensi')->nullable()->after('edukasi')
                ->comment('Respon pasien terhadap intervensi');
            $table->text('perubahan_klinis')->nullable()->after('respon_intervensi')
                ->comment('Perubahan kondisi klinis pasien');
            $table->text('tujuan_tercapai')->nullable()->after('perubahan_klinis')
                ->comment('Tujuan perawatan yang tercapai');
            $table->text('hambatan_perawatan')->nullable()->after('tujuan_tercapai')
                ->comment('Hambatan dalam perawatan');

            // Section 9: Rencana Lanjut (2 fields)
            $table->text('rencana_keperawatan')->nullable()->after('anjuran')
                ->comment('Rencana tindakan keperawatan lanjutan');
            $table->text('rencana_pemantauan')->nullable()->after('rencana_keperawatan')
                ->comment('Rencana pemantauan pasien');

            // Section 10: Rencana dengan Keluarga (3 fields)
            $table->text('keterlibatan_keluarga')->nullable()->after('rencana_pemantauan')
                ->comment('Keterlibatan keluarga dalam perawatan');
            $table->text('edukasi_keluarga')->nullable()->after('keterlibatan_keluarga')
                ->comment('Edukasi yang diberikan kepada keluarga');
            $table->text('dukungan_keluarga')->nullable()->after('edukasi_keluarga')
                ->comment('Dukungan keluarga yang dibutuhkan');

            // Section 11: Renpra - Nursing Care Plan (1 JSON field for 6 sub-fields)
            $table->json('renpra')->nullable()->after('dukungan_keluarga')
                ->comment('Rencana Perawatan: diagnosis, intervensi, tujuan, kriteria, rasional, evaluasi_renpra');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('resume_kegawatdaruratan_forms', function (Blueprint $table) {
            $table->dropColumn([
                // Anamnesis Extended
                'faktor_pencetus',
                // Pemeriksaan Fisik Extended
                'keadaan_umum',
                'tanda_vital',
                'pemeriksaan_lain',
                // Status Mental Extended
                'orientasi',
                'bentuk_pemikiran',
                'isi_pemikiran',
                // Diagnosis Extended
                'diagnosis_banding',
                'diagnosis_tambahan',
                'tindakan_keperawatan',
                'terapi_psikososial',
                // Implementasi
                'pelaksanaan_intervensi',
                'kolaborasi_tim',
                'edukasi',
                // Evaluasi
                'respon_intervensi',
                'perubahan_klinis',
                'tujuan_tercapai',
                'hambatan_perawatan',
                // Rencana Lanjut
                'rencana_keperawatan',
                'rencana_pemantauan',
                // Rencana Keluarga
                'keterlibatan_keluarga',
                'edukasi_keluarga',
                'dukungan_keluarga',
                // Renpra
                'renpra',
            ]);
        });
    }
};
