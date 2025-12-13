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
        Schema::table('sap_forms', function (Blueprint $table) {
            // Rename evaluasi_struktur to evaluasi_input (more accurate based on PDF)
            $table->renameColumn('evaluasi_struktur', 'evaluasi_input');

            // 6. PERINCIAN TUGAS (JOBLIST) - 6 JSON fields
            $table->json('joblist_penyuluh')->nullable()->after('kegiatan');
            $table->json('joblist_moderator')->nullable()->after('joblist_penyuluh');
            $table->json('joblist_fasilitator')->nullable()->after('joblist_moderator');
            $table->json('joblist_time_keeper')->nullable()->after('joblist_fasilitator');
            $table->json('joblist_dokumentator')->nullable()->after('joblist_time_keeper');
            $table->json('joblist_observer')->nullable()->after('joblist_dokumentator');

            // 7. PENGORGANISASIAN (Team Members) - 6 string fields
            $table->string('penyaji')->nullable()->after('joblist_observer');
            $table->string('moderator')->nullable()->after('penyaji');
            $table->string('fasilitator')->nullable()->after('moderator');
            $table->string('time_keeper')->nullable()->after('fasilitator');
            $table->string('dokumentator')->nullable()->after('time_keeper');
            $table->string('observer')->nullable()->after('dokumentator');

            // A. KEGIATAN PENYULUHAN - Alokasi Waktu Detail (4 int fields)
            $table->integer('waktu_pembukaan')->nullable()->after('observer')->comment('Waktu pembukaan dalam menit');
            $table->integer('waktu_penyampaian_materi')->nullable()->after('waktu_pembukaan')->comment('Waktu penyampaian materi dalam menit');
            $table->integer('waktu_tanya_jawab')->nullable()->after('waktu_penyampaian_materi')->comment('Waktu tanya jawab dalam menit');
            $table->integer('waktu_penutup')->nullable()->after('waktu_tanya_jawab')->comment('Waktu penutup dalam menit');

            // C. LAMPIRAN
            $table->text('daftar_pustaka')->nullable()->after('evaluasi_hasil');
            $table->string('setting_tempat_file_path')->nullable()->after('daftar_pustaka')->comment('Path untuk upload setting tempat');

            // D. HASIL EVALUASI PENYULUHAN - Info Pelaksanaan (10 fields)
            $table->date('hasil_hari_tanggal')->nullable()->after('setting_tempat_file_path')->comment('Tanggal pelaksanaan aktual');
            $table->time('hasil_waktu')->nullable()->after('hasil_hari_tanggal')->comment('Waktu pelaksanaan aktual');
            $table->text('hasil_sasaran')->nullable()->after('hasil_waktu');
            $table->string('hasil_moderator')->nullable()->after('hasil_sasaran');
            $table->string('hasil_penyaji')->nullable()->after('hasil_moderator');
            $table->string('hasil_observer')->nullable()->after('hasil_penyaji');
            $table->string('hasil_fasilitator')->nullable()->after('hasil_observer');
            $table->string('hasil_time_keeper')->nullable()->after('hasil_fasilitator');
            $table->string('hasil_dokumentator')->nullable()->after('hasil_time_keeper');
            $table->text('hasil_media')->nullable()->after('hasil_dokumentator');

            // D. HASIL EVALUASI PENYULUHAN - Checklist & Feedback (5 JSON fields)
            $table->json('hasil_evaluasi_input')->nullable()->after('hasil_media')->comment('5 checklist items untuk evaluasi input');
            $table->json('hasil_evaluasi_proses')->nullable()->after('hasil_evaluasi_input')->comment('9 items dengan dilakukan (bool) dan hambatan (text)');
            $table->json('hasil_evaluasi_seluruh')->nullable()->after('hasil_evaluasi_proses')->comment('5 checklist items untuk evaluasi keseluruhan');
            $table->json('pertanyaan_peserta')->nullable()->after('hasil_evaluasi_seluruh')->comment('Array of questions from participants');
            $table->json('saran_peserta')->nullable()->after('pertanyaan_peserta')->comment('Array of suggestions from participants');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sap_forms', function (Blueprint $table) {
            // Rename back
            $table->renameColumn('evaluasi_input', 'evaluasi_struktur');

            // Drop added columns
            $table->dropColumn([
                'joblist_penyuluh',
                'joblist_moderator',
                'joblist_fasilitator',
                'joblist_time_keeper',
                'joblist_dokumentator',
                'joblist_observer',
                'penyaji',
                'moderator',
                'fasilitator',
                'time_keeper',
                'dokumentator',
                'observer',
                'waktu_pembukaan',
                'waktu_penyampaian_materi',
                'waktu_tanya_jawab',
                'waktu_penutup',
                'daftar_pustaka',
                'setting_tempat_file_path',
                'hasil_hari_tanggal',
                'hasil_waktu',
                'hasil_sasaran',
                'hasil_moderator',
                'hasil_penyaji',
                'hasil_observer',
                'hasil_fasilitator',
                'hasil_time_keeper',
                'hasil_dokumentator',
                'hasil_media',
                'hasil_evaluasi_input',
                'hasil_evaluasi_proses',
                'hasil_evaluasi_seluruh',
                'pertanyaan_peserta',
                'saran_peserta',
            ]);
        });
    }
};
