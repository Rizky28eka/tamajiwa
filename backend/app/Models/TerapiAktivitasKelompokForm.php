<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class TerapiAktivitasKelompokForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        // A. Latar Belakang
        'latar_belakang',

        // B. Tujuan
        'tujuan_umum',
        'tujuan_khusus',

        // C. Persiapan Klien
        'karakteristik_klien',
        'proses_seleksi_klien',

        // D. Pengorganisasian
        'leader_sesi_1',
        'leader_sesi_2',
        'uraian_tugas_leader',
        'observer_fasilitator_sesi_1',
        'observer_fasilitator_sesi_2',
        'uraian_tugas_observer',

        // a. Jadwal
        'hari_tanggal',
        'waktu',
        'alokasi_waktu',
        'sasaran',
        'tempat',

        // b. Setting Tempat
        'keterangan_setting',
        'leader',
        'observer_fasilitator',
        'peserta',
        'pembimbing',

        // c & e. Alat & Metode
        'alat',
        'metode',

        // 4. Proses Pelaksanaan - Sesi 1
        'sesi_1_persiapan',
        'sesi_1_salam_terapeutik',
        'sesi_1_evaluasi_validasi',
        'sesi_1_kontrak',
        'sesi_1_fase_kerja',
        'sesi_1_evaluasi_terminasi',
        'sesi_1_tindak_lanjut',
        'sesi_1_kontrak_datang',

        // Sesi 2
        'sesi_2_persiapan',
        'sesi_2_salam_terapeutik',
        'sesi_2_evaluasi_validasi',
        'sesi_2_kontrak',
        'sesi_2_fase_kerja',
        'sesi_2_evaluasi_terminasi',
        'sesi_2_tindak_lanjut',
        'sesi_2_kontrak_datang',

        // Sesi 3
        'sesi_3_persiapan',
        'sesi_3_salam_terapeutik',
        'sesi_3_evaluasi_validasi',
        'sesi_3_kontrak',
        'sesi_3_fase_kerja',
        'sesi_3_evaluasi_terminasi',
        'sesi_3_tindak_lanjut',
        'sesi_3_kontrak_datang',

        // Sesi 4
        'sesi_4_persiapan',
        'sesi_4_salam_terapeutik',
        'sesi_4_evaluasi_validasi',
        'sesi_4_kontrak',
        'sesi_4_fase_kerja',
        'sesi_4_evaluasi_terminasi',
        'sesi_4_tindak_lanjut',
        'sesi_4_kontrak_datang',

        // Sesi 5
        'sesi_5_persiapan',
        'sesi_5_salam_terapeutik',
        'sesi_5_evaluasi_validasi',
        'sesi_5_kontrak',
        'sesi_5_fase_kerja',
        'sesi_5_evaluasi_terminasi',
        'sesi_5_tindak_lanjut',
        'sesi_5_kontrak_datang',

        // Evaluasi & Daftar Pustaka
        'evaluasi',
        'daftar_pustaka',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function form(): MorphOne
    {
        return $this->morphOne(Form::class, 'formable');
    }
}
