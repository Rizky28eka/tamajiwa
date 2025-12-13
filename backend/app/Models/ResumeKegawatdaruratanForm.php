<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class ResumeKegawatdaruratanForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        // Identitas
        'nama_pasien', 'no_rm', 'tanggal_masuk', 'jam_masuk', 'tanggal_keluar', 'jam_keluar',
        // Anamnesis
        'keluhan_utama', 'riwayat_penyakit_sekarang', 'riwayat_penyakit_dahulu', 'riwayat_pengobatan',
        'faktor_pencetus',
        // Pemeriksaan Fisik
        'keadaan_umum', 'tanda_vital',
        'kesadaran', 'gcs', 'tekanan_darah', 'nadi', 'suhu', 'pernapasan', 'spo2',
        'pemeriksaan_lain',
        // Status Mental
        'penampilan', 'perilaku', 'pembicaraan', 'mood_afek', 'pikiran', 'persepsi', 'kognitif',
        'orientasi', 'bentuk_pemikiran', 'isi_pemikiran',
        // Diagnosis & Tindakan
        'diagnosis_kerja', 'diagnosis_banding', 'diagnosis_tambahan',
        'tindakan_yang_dilakukan', 'tindakan_keperawatan', 'terapi_psikososial', 'terapi_obat',
        // Implementasi
        'pelaksanaan_intervensi', 'kolaborasi_tim', 'edukasi',
        // Evaluasi
        'respon_intervensi', 'perubahan_klinis', 'tujuan_tercapai', 'hambatan_perawatan',
        // Kondisi Keluar & Rencana
        'kondisi_keluar', 'anjuran',
        'rencana_keperawatan', 'rencana_pemantauan',
        // Rencana Keluarga
        'keterlibatan_keluarga', 'edukasi_keluarga', 'dukungan_keluarga',
        // Renpra (Nursing Care Plan)
        'renpra',
    ];

    protected $casts = [
        'tanggal_masuk' => 'date',
        'tanggal_keluar' => 'date',
        'renpra' => 'array', // Cast JSON to array
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
