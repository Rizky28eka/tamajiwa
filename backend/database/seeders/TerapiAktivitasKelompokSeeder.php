<?php

namespace Database\Seeders;

use App\Models\Patient;
use App\Models\TerapiAktivitasKelompokForm;
use App\Models\User;
use Illuminate\Database\Seeder;

class TerapiAktivitasKelompokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $mahasiswas = User::where('role', 'mahasiswa')->get();
        $patients = Patient::all();
        $faker = \Faker\Factory::create('id_ID');

        if ($mahasiswas->isEmpty() || $patients->isEmpty()) {
            $this->command->warn('Skipping TerapiAktivitasKelompokSeeder: No mahasiswa or patients found');
            return;
        }

        // Create 20 TAK forms
        for ($i = 0; $i < 20; $i++) {
            TerapiAktivitasKelompokForm::create([
                'user_id' => $mahasiswas->random()->id,
                'patient_id' => $patients->random()->id,
                'status' => $faker->randomElement(['draft', 'submitted', 'approved']),

                // A. Latar Belakang
                'latar_belakang' => $faker->paragraph,

                // B. Tujuan
                'tujuan_umum' => $faker->sentence,
                'tujuan_khusus' => $faker->paragraph,

                // C. Persiapan Klien
                'karakteristik_klien' => $faker->sentence,
                'proses_seleksi_klien' => $faker->sentence,

                // D. Pengorganisasian
                'leader_sesi_1' => $faker->name,
                'leader_sesi_2' => $faker->name,
                'uraian_tugas_leader' => $faker->paragraph,
                'observer_fasilitator_sesi_1' => $faker->name,
                'observer_fasilitator_sesi_2' => $faker->name,
                'uraian_tugas_observer' => $faker->paragraph,

                // a. Jadwal
                'hari_tanggal' => $faker->dateTimeBetween('-1 month', 'now')->format('l, d F Y'),
                'waktu' => '09:00 - 10:00 WIB',
                'alokasi_waktu' => '60 menit',
                'sasaran' => rand(5, 12) . ' orang pasien',
                'tempat' => $faker->randomElement(['Ruang Rekreasi', 'Taman', 'Ruang Serbaguna']),

                // b. Setting Tempat
                'keterangan_setting' => $faker->sentence,
                'leader' => 'Posisi di tengah',
                'observer_fasilitator' => 'Posisi menyebar',
                'peserta' => 'Melingkar',
                'pembimbing' => 'Di belakang observer',

                // c & e. Alat & Metode
                'alat' => $faker->paragraph,
                'metode' => $faker->sentence,

                // Sesi 1-5 (Simplified for loop, using placeholders)
                'sesi_1_persiapan' => $faker->sentence,
                'sesi_1_salam_terapeutik' => $faker->sentence,
                'sesi_1_evaluasi_validasi' => $faker->sentence,
                'sesi_1_kontrak' => $faker->sentence,
                'sesi_1_fase_kerja' => $faker->paragraph,
                'sesi_1_evaluasi_terminasi' => $faker->sentence,
                'sesi_1_tindak_lanjut' => $faker->sentence,
                'sesi_1_kontrak_datang' => $faker->sentence,

                'sesi_2_persiapan' => $faker->sentence,
                'sesi_2_salam_terapeutik' => $faker->sentence,
                'sesi_2_evaluasi_validasi' => $faker->sentence,
                'sesi_2_kontrak' => $faker->sentence,
                'sesi_2_fase_kerja' => $faker->paragraph,
                'sesi_2_evaluasi_terminasi' => $faker->sentence,
                'sesi_2_tindak_lanjut' => $faker->sentence,
                'sesi_2_kontrak_datang' => $faker->sentence,

                'sesi_3_persiapan' => $faker->sentence,
                'sesi_3_salam_terapeutik' => $faker->sentence,
                'sesi_3_evaluasi_validasi' => $faker->sentence,
                'sesi_3_kontrak' => $faker->sentence,
                'sesi_3_fase_kerja' => $faker->paragraph,
                'sesi_3_evaluasi_terminasi' => $faker->sentence,
                'sesi_3_tindak_lanjut' => $faker->sentence,
                'sesi_3_kontrak_datang' => $faker->sentence,

                'sesi_4_persiapan' => $faker->sentence,
                'sesi_4_salam_terapeutik' => $faker->sentence,
                'sesi_4_evaluasi_validasi' => $faker->sentence,
                'sesi_4_kontrak' => $faker->sentence,
                'sesi_4_fase_kerja' => $faker->paragraph,
                'sesi_4_evaluasi_terminasi' => $faker->sentence,
                'sesi_4_tindak_lanjut' => $faker->sentence,
                'sesi_4_kontrak_datang' => $faker->sentence,

                'sesi_5_persiapan' => $faker->sentence,
                'sesi_5_salam_terapeutik' => $faker->sentence,
                'sesi_5_evaluasi_validasi' => $faker->sentence,
                'sesi_5_kontrak' => $faker->sentence,
                'sesi_5_fase_kerja' => $faker->paragraph,
                'sesi_5_evaluasi_terminasi' => $faker->sentence,
                'sesi_5_tindak_lanjut' => $faker->sentence,
                'sesi_5_kontrak_datang' => $faker->sentence,

                // Evaluasi & Daftar Pustaka
                'evaluasi' => $faker->paragraph,
                'daftar_pustaka' => $faker->paragraph,
            ]);
        }
        
        $this->command->info('20 Sample Terapi Aktivitas Kelompok forms created successfully!');
    }
}
