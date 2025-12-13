<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class StrategiPelaksanaanKomunikasiForm extends Model
{
    protected $fillable = [
        'user_id',
        'patient_id',
        'status',

        // A. Proses Keperawatan
        'kondisi_klien',
        'diagnosa_keperawatan',
        'tujuan',
        'tindakan_keperawatan',

        // B. Strategi Komunikasi - Fase Orientasi
        'salam_terapeutik',
        'evaluasi_validasi',
        'kontrak_orientasi',
        'menjaga_kerahasiaan',

        // Fase Kerja
        'fase_kerja',

        // Fase Terminasi
        'evaluasi_subjektif',
        'evaluasi_objektif',
        'rencana_tindak_lanjut',
        'kontrak_terminasi',
    ];

    protected $casts = [
        'tindakan_keperawatan' => 'array',
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
