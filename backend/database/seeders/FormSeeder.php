<?php

namespace Database\Seeders;

use App\Models\Form;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class FormSeeder extends Seeder
{
    public function run(): void
    {
        $mahasiswas = User::where('role', 'mahasiswa')->get();
        $patients = Patient::all();
        $faker = \Faker\Factory::create('id_ID');

        foreach ($patients as $patient) {
            // Assign 1-3 forms per patient
            $numForms = rand(1, 3);
            
            for ($i = 0; $i < $numForms; $i++) {
                $formType = $faker->randomElement([
                    'pengkajian', 
                    'resume_kegawatdaruratan', 
                    'resume_poliklinik', 
                    'sap', 
                    'catatan_tambahan'
                ]);

                $data = $this->generateFormData($formType, $patient, $faker);
                
                Form::create([
                    'type' => $formType,
                    'user_id' => $mahasiswas->isNotEmpty() ? $mahasiswas->random()->id : 1, // Fallback to id 1 if empty
                    'patient_id' => $patient->id,
                    'status' => $faker->randomElement(['submitted', 'approved', 'rejected', 'draft']),
                    'data' => $data,
                    'created_at' => $faker->dateTimeBetween('-6 months', 'now'),
                    'updated_at' => now(),
                ]);
            }
        }
    }

    private function generateFormData($type, $patient, $faker)
    {
        switch ($type) {
            case 'pengkajian':
                return [
                    'nama_lengkap' => $patient->name,
                    'umur' => (string) $patient->age,
                    'jenis_kelamin' => $patient->gender,
                    'status_perkawinan' => $faker->randomElement(['menikah', 'belum_menikah', 'janda', 'duda']),
                    'riwayat_pendidikan' => $faker->sentence,
                    'pekerjaan' => $faker->jobTitle,
                    'riwayat_keluarga' => $faker->paragraph,
                    'hubungan_sosial' => $faker->sentence,
                    'dukungan_sosial' => $faker->sentence,
                    'stresor_psikososial' => $faker->sentence,
                    'riwayat_gangguan_psikiatri' => $faker->paragraph,
                    'kesadaran' => $faker->randomElement(['sadar_penuh', 'apatis', 'delirium']),
                    'orientasi' => $faker->randomElement(['utuh', 'terganggu']),
                    'penampilan' => $faker->sentence,
                    'mood' => $faker->randomElement(['eutimik', 'hipotimik', 'hipertimik', 'disforik']),
                    'afect' => $faker->randomElement(['luas', 'sempit', 'tumpul', 'datar']),
                    'alam_pikiran' => $faker->sentence,
                    'fungsi_sosial' => $faker->sentence,
                    'kepercayaan' => 'Islam',
                    'praktik_ibadah' => 'Rutin',
                    'diagnosis' => 1,
                    'intervensi' => [1, 2],
                    'tujuan' => $faker->sentence,
                    'kriteria' => $faker->sentence,
                    'rasional' => $faker->sentence,
                    'catatan_tambahan' => $faker->sentence,
                    'tanggal_pengisian' => now()->toIso8601String(),
                ];
            case 'resume_kegawatdaruratan':
                return [
                    'nama_lengkap' => $patient->name,
                    'umur' => $patient->age,
                    'jenis_kelamin' => $patient->gender == 'L' ? 'Laki-laki' : 'Perempuan',
                    'alamat' => $patient->address,
                    'tanggal_masuk' => now()->subDays(rand(1, 30))->toIso8601String(),
                    'keluhan_utama' => $faker->sentence,
                    'riwayat_penyakit_sekarang' => $faker->paragraph,
                    'faktor_pencetus' => $faker->sentence,
                    'keadaan_umum' => $faker->sentence,
                    'tanda_vital' => 'TD: 120/80, N: 80, S: 36.5',
                    'pemeriksaan_lain' => '-',
                    'kesadaran' => 'Compos mentis',
                    'orientasi' => 'Baik',
                    'bentuk_pemikiran' => 'Realistik',
                    'isi_pemikiran' => 'Tidak ada waham',
                    'persepsi' => 'Tidak ada halusinasi',
                    'diagnosis_utama' => $faker->sentence,
                    'diagnosis_banding' => '-',
                    'diagnosis_tambahan' => '-',
                    'tindakan_medis' => $faker->sentence,
                    'tindakan_keperawatan' => $faker->sentence,
                    'terapi_psikososial' => $faker->sentence,
                    'renpra_diagnosis' => $faker->sentence,
                    'renpra_intervensi' => $faker->sentence,
                    'renpra_tujuan' => $faker->sentence,
                    'renpra_kriteria' => $faker->sentence,
                    'renpra_rasional' => $faker->sentence,
                ];
            case 'resume_poliklinik':
                 return [
                    'nama_lengkap' => $patient->name,
                    'umur' => $patient->age,
                    'jenis_kelamin' => $patient->gender == 'L' ? 'Laki-laki' : 'Perempuan',
                    'status_perkawinan' => 'Menikah',
                    'riwayat_pendidikan' => 'SMA',
                    'pekerjaan' => 'Swasta',
                    'riwayat_keluarga' => '-',
                    'hubungan_sosial' => 'Baik',
                    'dukungan_sosial' => 'Keluarga',
                    'stresor_psikososial' => 'Ekonomi',
                    'riwayat_gangguan_psikiatri' => '-',
                    'riwayat_pengobatan' => '-',
                    'kesadaran' => 'Compos mentis',
                    'orientasi' => 'Baik',
                    'penampilan' => 'Rapi',
                    'mood' => 'Baik',
                    'afect' => 'Sesuai',
                    'alam_pikiran' => 'Realistik',
                    'fungsi_sosial' => 'Baik',
                    'interaksi_sosial' => 'Kooperatif',
                    'kepercayaan' => 'Islam',
                    'praktik_ibadah' => 'Baik',
                    'diagnosis' => $faker->sentence,
                    'intervensi' => $faker->sentence,
                    'tujuan' => $faker->sentence,
                    'kriteria' => $faker->sentence,
                    'rasional' => $faker->sentence,
                    'catatan_tambahan' => '-',
                    'tanggal_pengisian' => now()->toIso8601String(),
                ];
            case 'sap':
                return [
                    'topik' => $faker->sentence(3),
                    'sub_topik' => $faker->word,
                    'sasaran' => 'Pasien',
                    'tanggal_pelaksanaan' => now()->toIso8601String(),
                    'waktu_pelaksanaan' => '10:00',
                    'tempat' => 'Ruang Rawat',
                    'durasi' => '30 menit',
                    'tujuan_umum' => $faker->sentence,
                    'tujuan_khusus' => $faker->sentence,
                    'materi_penyuluhan' => $faker->paragraph,
                    'metode' => ['Ceramah', 'Tanya Jawab'],
                    'media' => ['Leaflet'],
                    'kegiatan' => [
                        ['tahap' => 'Pendahuluan', 'kegiatan_penyuluh' => 'Salam', 'kegiatan_peserta' => 'Menjawab', 'waktu' => '5 menit'],
                        ['tahap' => 'Isi', 'kegiatan_penyuluh' => 'Materi', 'kegiatan_peserta' => 'Menyimak', 'waktu' => '20 menit'],
                        ['tahap' => 'Penutup', 'kegiatan_penyuluh' => 'Evaluasi', 'kegiatan_peserta' => 'Menjawab', 'waktu' => '5 menit'],
                    ],
                    'evaluasi_struktur' => 'Siap',
                    'evaluasi_proses' => 'Lancar',
                    'evaluasi_hasil' => 'Paham',
                    'penyuluh' => 'Mahasiswa',
                    'moderator' => '-',
                    'fasilitator' => '-',
                    'renpra_diagnosis' => $faker->word,
                    'renpra_intervensi' => $faker->sentence,
                    'renpra_tujuan' => $faker->sentence,
                    'renpra_kriteria' => $faker->sentence,
                    'renpra_rasional' => $faker->sentence,
                ];
            case 'catatan_tambahan':
                return [
                    'tanggal_catatan' => now()->toIso8601String(),
                    'waktu_catatan' => now()->format('H:i'),
                    'kategori' => $faker->randomElement(['Perkembangan', 'Insiden', 'Lainnya']),
                    'catatan' => $faker->paragraph,
                    'tindak_lanjut' => $faker->sentence,
                ];
            default:
                return [];
        }
    }
}
