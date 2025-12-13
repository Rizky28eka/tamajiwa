<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class CatatanTambahanForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        'tanggal_catatan', 'waktu_catatan', 'kategori', 'catatan', 'tindak_lanjut',
        'renpra', // Rencana Perawatan (JSON)
    ];

    protected $casts = [
        'tanggal_catatan' => 'date',
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
