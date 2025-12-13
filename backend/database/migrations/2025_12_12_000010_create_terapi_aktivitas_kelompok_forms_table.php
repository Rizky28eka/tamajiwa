<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('terapi_aktivitas_kelompok_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');

            // A. Latar Belakang
            $table->text('latar_belakang')->nullable();

            // B. Tujuan Terapi Aktivitas Kelompok
            $table->text('tujuan_umum')->nullable();
            $table->text('tujuan_khusus')->nullable();

            // C. Persiapan Klien
            $table->text('karakteristik_klien')->nullable();
            $table->text('proses_seleksi_klien')->nullable();

            // D. Pengorganisasian
            $table->string('leader_sesi_1')->nullable();
            $table->string('leader_sesi_2')->nullable();
            $table->text('uraian_tugas_leader')->nullable();
            $table->string('observer_fasilitator_sesi_1')->nullable();
            $table->string('observer_fasilitator_sesi_2')->nullable();
            $table->text('uraian_tugas_observer')->nullable();

            // a. Jadwal Pelaksanaan
            $table->string('hari_tanggal')->nullable();
            $table->string('waktu')->nullable();
            $table->string('alokasi_waktu')->nullable(); // menit
            $table->string('sasaran')->nullable(); // jumlah pasien
            $table->string('tempat')->nullable();

            // b. Setting Tempat
            $table->text('keterangan_setting')->nullable();
            $table->string('leader')->nullable(); // keterangan posisi
            $table->string('observer_fasilitator')->nullable();
            $table->string('peserta')->nullable();
            $table->string('pembimbing')->nullable();

            // c & e. Alat & Metode
            $table->text('alat')->nullable();
            $table->text('metode')->nullable();

            // 4. Proses Pelaksanaan TAK - Sesi 1
            $table->text('sesi_1_persiapan')->nullable();
            $table->text('sesi_1_salam_terapeutik')->nullable();
            $table->text('sesi_1_evaluasi_validasi')->nullable();
            $table->text('sesi_1_kontrak')->nullable();
            $table->text('sesi_1_fase_kerja')->nullable();
            $table->text('sesi_1_evaluasi_terminasi')->nullable();
            $table->text('sesi_1_tindak_lanjut')->nullable();
            $table->text('sesi_1_kontrak_datang')->nullable();

            // Sesi 2
            $table->text('sesi_2_persiapan')->nullable();
            $table->text('sesi_2_salam_terapeutik')->nullable();
            $table->text('sesi_2_evaluasi_validasi')->nullable();
            $table->text('sesi_2_kontrak')->nullable();
            $table->text('sesi_2_fase_kerja')->nullable();
            $table->text('sesi_2_evaluasi_terminasi')->nullable();
            $table->text('sesi_2_tindak_lanjut')->nullable();
            $table->text('sesi_2_kontrak_datang')->nullable();

            // Sesi 3
            $table->text('sesi_3_persiapan')->nullable();
            $table->text('sesi_3_salam_terapeutik')->nullable();
            $table->text('sesi_3_evaluasi_validasi')->nullable();
            $table->text('sesi_3_kontrak')->nullable();
            $table->text('sesi_3_fase_kerja')->nullable();
            $table->text('sesi_3_evaluasi_terminasi')->nullable();
            $table->text('sesi_3_tindak_lanjut')->nullable();
            $table->text('sesi_3_kontrak_datang')->nullable();

            // Sesi 4
            $table->text('sesi_4_persiapan')->nullable();
            $table->text('sesi_4_salam_terapeutik')->nullable();
            $table->text('sesi_4_evaluasi_validasi')->nullable();
            $table->text('sesi_4_kontrak')->nullable();
            $table->text('sesi_4_fase_kerja')->nullable();
            $table->text('sesi_4_evaluasi_terminasi')->nullable();
            $table->text('sesi_4_tindak_lanjut')->nullable();
            $table->text('sesi_4_kontrak_datang')->nullable();

            // Sesi 5
            $table->text('sesi_5_persiapan')->nullable();
            $table->text('sesi_5_salam_terapeutik')->nullable();
            $table->text('sesi_5_evaluasi_validasi')->nullable();
            $table->text('sesi_5_kontrak')->nullable();
            $table->text('sesi_5_fase_kerja')->nullable();
            $table->text('sesi_5_evaluasi_terminasi')->nullable();
            $table->text('sesi_5_tindak_lanjut')->nullable();
            $table->text('sesi_5_kontrak_datang')->nullable();

            // Evaluasi & Daftar Pustaka
            $table->text('evaluasi')->nullable();
            $table->text('daftar_pustaka')->nullable();

            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('terapi_aktivitas_kelompok_forms');
    }
};
