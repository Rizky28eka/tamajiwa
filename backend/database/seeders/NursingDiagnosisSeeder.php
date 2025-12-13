<?php

namespace Database\Seeders;

use App\Models\NursingDiagnosis;
use App\Models\User;
use Illuminate\Database\Seeder;

class NursingDiagnosisSeeder extends Seeder
{
    public function run(): void
    {
        // Get a dosen user to assign as creator
        $dosen = User::where('role', 'dosen')->first();

        // If no dosen exists, create one for seeding purposes
        if (! $dosen) {
            $dosen = User::create([
                'name' => 'Dr. Default Dosen',
                'username' => 'dosen_default',
                'email' => 'dosen@example.com',
                'password' => bcrypt('password'),
                'role' => 'dosen',
            ]);
        }

        NursingDiagnosis::create([
            'name' => 'Ansietas',
            'description' => 'Diagnosa keperawatan untuk pasien dengan gangguan kecemasan',
            'created_by' => $dosen->id,
        ]);

        NursingDiagnosis::create([
            'name' => 'Gangguan Persepsi Sensori: Halusinasi',
            'description' => 'Diagnosa untuk pasien dengan halusinasi pendengaran atau visual',
            'created_by' => $dosen->id,
        ]);

        NursingDiagnosis::create([
            'name' => 'Gangguan Proses Pikir',
            'description' => 'Diagnosa untuk pasien dengan gangguan kognitif dan konsentrasi',
            'created_by' => $dosen->id,
        ]);

        NursingDiagnosis::create([
            'name' => 'Koping Individu Tidak Efektif',
            'description' => 'Diagnosa untuk pasien dengan mekanisme koping yang tidak adaptif',
            'created_by' => $dosen->id,
        ]);

        NursingDiagnosis::create([
            'name' => 'Isolasi Sosial',
            'description' => 'Diagnosa untuk pasien yang menarik diri dari interaksi sosial',
            'created_by' => $dosen->id,
        ]);

        NursingDiagnosis::create([
            'name' => 'Risiko Perilaku Kekerasan',
            'description' => 'Diagnosa untuk pasien dengan risiko mencederai diri atau orang lain',
            'created_by' => $dosen->id,
        ]);
    }
}
