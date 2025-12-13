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
        Schema::table('resume_poliklinik_forms', function (Blueprint $table) {
            // Identitas Extended
            $table->integer('umur')->nullable()->after('poliklinik');
            $table->enum('jenis_kelamin', ['L', 'P'])->nullable()->after('umur');
            $table->string('status_perkawinan')->nullable()->after('jenis_kelamin');

            // Riwayat Kehidupan & Psikososial
            $table->text('riwayat_pendidikan')->nullable()->after('riwayat_alergi');
            $table->string('pekerjaan')->nullable()->after('riwayat_pendidikan');
            $table->text('riwayat_keluarga')->nullable()->after('pekerjaan');
            $table->text('hubungan_sosial')->nullable()->after('riwayat_keluarga');
            $table->text('dukungan_sosial')->nullable()->after('hubungan_sosial');
            $table->text('stresor_psikososial')->nullable()->after('dukungan_sosial');
            $table->text('riwayat_gangguan_psikiatri')->nullable()->after('stresor_psikososial'); // Additional specific history

            // Pemeriksaan & Status Mental Extended
            $table->text('orientasi')->nullable()->after('tinggi_badan');
            $table->text('alam_pikiran')->nullable()->after('pikiran');

            // Fungsi Sosial
            $table->text('fungsi_sosial')->nullable()->after('edukasi');
            $table->text('interaksi_sosial')->nullable()->after('fungsi_sosial');

            // Fungsi Spiritual
            $table->text('kepercayaan')->nullable()->after('interaksi_sosial');
            $table->text('praktik_ibadah')->nullable()->after('kepercayaan');

            // Penutup
            $table->text('catatan_tambahan')->nullable()->after('rencana_tindak_lanjut');
            $table->date('tanggal_pengisian')->nullable()->after('catatan_tambahan');

            // Renpra (JSON)
            $table->json('renpra')->nullable()->after('tanggal_pengisian')
                ->comment('Rencana Perawatan: diagnosis, intervensi, tujuan, kriteria, rasional');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('resume_poliklinik_forms', function (Blueprint $table) {
            $table->dropColumn([
                'umur',
                'jenis_kelamin',
                'status_perkawinan',
                'riwayat_pendidikan',
                'pekerjaan',
                'riwayat_keluarga',
                'hubungan_sosial',
                'dukungan_sosial',
                'stresor_psikososial',
                'riwayat_gangguan_psikiatri',
                'orientasi',
                'alam_pikiran',
                'fungsi_sosial',
                'interaksi_sosial',
                'kepercayaan',
                'praktik_ibadah',
                'catatan_tambahan',
                'tanggal_pengisian',
                'renpra',
            ]);
        });
    }
};
