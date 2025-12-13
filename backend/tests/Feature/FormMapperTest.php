<?php

namespace Tests\Feature;

use App\Models\Form;
use App\Models\NursingDiagnosis;
use App\Models\NursingIntervention;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FormMapperTest extends TestCase
{
    use RefreshDatabase;

    private $user;
    private $patient;

    protected function setUp(): void
    {
        parent::setUp();
        // Create user and patient tokens/auth
        $this->user = User::factory()->create();
        $this->patient = Patient::factory()->create(['created_by' => $this->user->id]);
    }

    /**
     * Test mapping and storage for Strategi Pelaksanaan Komunikasi
     */
    public function test_strategi_pelaksanaan_komunikasi_mapping()
    {
        $this->actingAs($this->user);

        // Seeding dummy nursing data for validation
        $diagnosis = NursingDiagnosis::create([
            'name' => 'Ansietas', 
            'code' => 'D.0080',
            'created_by' => $this->user->id
        ]);
        $intervention = NursingIntervention::create([
            'name' => 'Terapi Relaksasi', 
            'description' => '...',
            'created_by' => $this->user->id
        ]);

        // Data payload mimicking Flutter FormDataMapper output for this form type
        // Refer to StrategiPelaksanaanKomunikasiMapper.dart
        $mappedData = [
            'type' => 'strategi_pelaksanaan_komunikasi',
            'patient_id' => $this->patient->id,
            'status' => 'submitted',
            'data' => [
                // Basic Info
                'patient_id' => $this->patient->id,
                'status' => 'submitted',
                
                // Section A
                'kondisi_klien' => 'Klien tampak gelisah',
                'diagnosa_keperawatan' => $diagnosis->id, // ID from DB
                'tujuan' => 'Klien mampu mengontrol kecemasan',
                'tindakan_keperawatan' => [$intervention->id], // List<int>
                
                // Section B - Orientasi
                'salam_terapeutik' => 'Selamat pagi bapak',
                'evaluasi_validasi' => 'Bagaimana perasaan bapak hari ini?',
                'kontrak_orientasi' => 'Kita bercakap-cakap 15 menit',
                'menjaga_kerahasiaan' => 'Pembicaraan ini rahasia',
                
                // Section B - Kerja
                'fase_kerja' => 'Saya ajarkan teknik napas dalam...',
                
                // Section B - Terminasi
                'evaluasi_subjektif' => 'Saya merasa lebih tenang',
                'evaluasi_objektif' => 'Klien tampak rileks',
                'rencana_tindak_lanjut' => 'Latihan 3x sehari',
                'kontrak_terminasi' => 'Besok kita ketemu lagi jam 9',
            ]
        ];

        $response = $this->postJson('/api/forms', $mappedData);

        $response->assertStatus(201);
        $response->assertJsonPath('form.type', 'strategi_pelaksanaan_komunikasi');

        // Verify data in specific table
        $this->assertDatabaseHas('strategi_pelaksanaan_komunikasi_forms', [
            'kondisi_klien' => 'Klien tampak gelisah',
            'diagnosa_keperawatan' => $diagnosis->id,
            'fase_kerja' => 'Saya ajarkan teknik napas dalam...',
            // Check casting/json storage
            'tindakan_keperawatan' => json_encode([$intervention->id]),
        ]);
        
        // Verify main forms table
        $this->assertDatabaseHas('forms', [
            'type' => 'strategi_pelaksanaan_komunikasi',
            'patient_id' => $this->patient->id,
            'user_id' => $this->user->id,
        ]);
    }

    /**
     * Test mapping and storage for Terapi Aktivitas Kelompok
     */
    public function test_terapi_aktivitas_kelompok_mapping()
    {
        $this->actingAs($this->user);

        // Data payload mimicking Flutter FormDataMapper output
        // Refer to TerapiAktivitasKelompokMapper.dart
        $mappedData = [
            'type' => 'terapi_aktivitas_kelompok',
            'patient_id' => $this->patient->id,
            'status' => 'submitted',
            'data' => [
                'patient_id' => $this->patient->id,
                'status' => 'submitted',
                
                'latar_belakang' => 'Klien dengan isolasi sosial...',
                'tujuan_umum' => 'Meningkatkan interaksi',
                'tujuan_khusus' => 'Mampu berkenalan',
                
                'karakteristik_klien' => 'Kooperatif',
                'proses_seleksi_klien' => 'Wawancara',
                
                'leader_sesi_1' => 'Perawat A',
                'uraian_tugas_leader' => 'Memimpin sesi',
                
                'hari_tanggal' => 'Senin, 1 Jan 2024',
                'waktu' => '09:00 WIB',
                'tempat' => 'Ruang TAK',
                
                'keterangan_setting' => 'Lingkaran',
                'alat' => 'Bola, Musik',
                
                // Nested Session Data (Sesi 1)
                'sesi_1_persiapan' => 'Siapkan alat',
                'sesi_1_salam_terapeutik' => 'Halo semua',
                'sesi_1_fase_kerja' => 'Lempar bola',
                'sesi_1_evaluasi_terminasi' => 'Semua senang',
                
                'evaluasi' => 'Berjalan lancar',
                'daftar_pustaka' => 'Buku Keperawatan Jiwa',
            ]
        ];

        $response = $this->postJson('/api/forms', $mappedData);

        $response->assertStatus(201);
        
        $this->assertDatabaseHas('terapi_aktivitas_kelompok_forms', [
            'latar_belakang' => 'Klien dengan isolasi sosial...',
            'tujuan_umum' => 'Meningkatkan interaksi',
            'leader_sesi_1' => 'Perawat A',
            'hari_tanggal' => 'Senin, 1 Jan 2024',
            'sesi_1_fase_kerja' => 'Lempar bola',
            'daftar_pustaka' => 'Buku Keperawatan Jiwa',
        ]);
    }
}
