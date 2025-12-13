<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class ResumePoliklinikForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        // Identitas
        'nama_pasien', 'no_rm', 'tanggal_kunjungan', 'poliklinik',
        'umur', 'jenis_kelamin', 'status_perkawinan',
        // Anamnesis & Riwayat
        'keluhan_utama', 'riwayat_penyakit_sekarang', 'riwayat_penyakit_dahulu',
        'riwayat_pengobatan', 'riwayat_alergi',
        'riwayat_pendidikan', 'pekerjaan', 'riwayat_keluarga',
        'riwayat_gangguan_psikiatri',
        // Psikososial
        'hubungan_sosial', 'dukungan_sosial', 'stresor_psikososial',
        // Pemeriksaan Fisik
        'kesadaran', 'tekanan_darah', 'nadi', 'suhu', 'pernapasan', 'berat_badan', 'tinggi_badan',
        'orientasi',
        // Status Mental
        'penampilan', 'perilaku', 'mood_afek', 'pikiran', 'alam_pikiran',
        // Diagnosis & Terapi
        'diagnosis', 'terapi_farmakologi', 'terapi_non_farmakologi', 'edukasi',
        // Fungsi Sosial & Spiritual
        'fungsi_sosial', 'interaksi_sosial',
        'kepercayaan', 'praktik_ibadah',
        // Tindak Lanjut & Penutup
        'tanggal_kontrol_berikutnya', 'rencana_tindak_lanjut',
        'catatan_tambahan', 'tanggal_pengisian',
        // Renpra
        'renpra',
    ];

    protected $casts = [
        'tanggal_kunjungan' => 'date',
        'tanggal_kontrol_berikutnya' => 'date',
        'tanggal_pengisian' => 'date',
        'renpra' => 'array',
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
