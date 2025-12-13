<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class SapForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        // Identitas SAP
        'topik', 'sub_topik', 'sasaran', 'tanggal_pelaksanaan', 'waktu_pelaksanaan',
        'tempat', 'durasi',
        // Tujuan
        'tujuan_umum', 'tujuan_khusus',
        // Materi
        'materi_penyuluhan',
        // Metode & Media
        'metode', 'media',
        // Kegiatan
        'kegiatan',
        // Joblist (Perincian Tugas)
        'joblist_penyuluh', 'joblist_moderator', 'joblist_fasilitator',
        'joblist_time_keeper', 'joblist_dokumentator', 'joblist_observer',
        // Pengorganisasian (Team Members)
        'penyaji', 'moderator', 'fasilitator', 'time_keeper', 'dokumentator', 'observer',
        // Alokasi Waktu Detail
        'waktu_pembukaan', 'waktu_penyampaian_materi', 'waktu_tanya_jawab', 'waktu_penutup',
        // Evaluasi
        'evaluasi_input', 'evaluasi_proses', 'evaluasi_hasil',
        // Lampiran
        'daftar_pustaka', 'materi_file_path', 'dokumentasi_foto_path', 'setting_tempat_file_path',
        // Hasil Evaluasi - Info Pelaksanaan
        'hasil_hari_tanggal', 'hasil_waktu', 'hasil_sasaran', 'hasil_moderator',
        'hasil_penyaji', 'hasil_observer', 'hasil_fasilitator', 'hasil_time_keeper',
        'hasil_dokumentator', 'hasil_media',
        // Hasil Evaluasi - Checklists & Feedback
        'hasil_evaluasi_input', 'hasil_evaluasi_proses', 'hasil_evaluasi_seluruh',
        'pertanyaan_peserta', 'saran_peserta',
    ];

    protected $casts = [
        'tanggal_pelaksanaan' => 'date',
        'hasil_hari_tanggal' => 'date',
        'hasil_waktu' => 'datetime',
        'metode' => 'array',
        'media' => 'array',
        'kegiatan' => 'array',
        'joblist_penyuluh' => 'array',
        'joblist_moderator' => 'array',
        'joblist_fasilitator' => 'array',
        'joblist_time_keeper' => 'array',
        'joblist_dokumentator' => 'array',
        'joblist_observer' => 'array',
        'hasil_evaluasi_input' => 'array',
        'hasil_evaluasi_proses' => 'array',
        'hasil_evaluasi_seluruh' => 'array',
        'pertanyaan_peserta' => 'array',
        'saran_peserta' => 'array',
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
