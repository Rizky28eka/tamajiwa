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
        Schema::table('pengkajian_forms', function (Blueprint $table) {
            // Identitas Ext
            $table->string('status_perkawinan')->nullable()->after('jenis_kelamin');

            // Riwayat Ext
            $table->text('riwayat_pendidikan')->nullable()->after('pendidikan');
            $table->text('riwayat_keluarga')->nullable()->after('riwayat_penyakit_keluarga');
            $table->text('riwayat_gangguan_psikiatri')->nullable()->after('riwayat_pengobatan');

            // Psikososial & Spiritual Ext
            $table->text('dukungan_sosial')->nullable()->after('spiritual');
            $table->text('stresor_psikososial')->nullable()->after('dukungan_sosial');
            $table->text('fungsi_sosial')->nullable()->after('stresor_psikososial');
            $table->text('kepercayaan')->nullable()->after('fungsi_sosial');
            $table->text('praktik_ibadah')->nullable()->after('kepercayaan');

            // Status Mental Ext
            $table->text('alam_pikiran')->nullable()->after('isi_pikir');

            // Penutup
            $table->text('catatan_tambahan')->nullable()->after('terapi_medis');
            $table->date('tanggal_pengisian')->nullable()->after('catatan_tambahan');

            // Renpra
            $table->json('renpra')->nullable()->after('tanggal_pengisian')
                ->comment('Rencana Perawatan: diagnosis, intervensi, tujuan, kriteria, rasional');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pengkajian_forms', function (Blueprint $table) {
            $table->dropColumn([
                'status_perkawinan',
                'riwayat_pendidikan',
                'riwayat_keluarga',
                'riwayat_gangguan_psikiatri',
                'dukungan_sosial',
                'stresor_psikososial',
                'fungsi_sosial',
                'kepercayaan',
                'praktik_ibadah',
                'alam_pikiran',
                'catatan_tambahan',
                'tanggal_pengisian',
                'renpra',
            ]);
        });
    }
};
