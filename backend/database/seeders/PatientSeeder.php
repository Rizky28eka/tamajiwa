<?php

namespace Database\Seeders;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class PatientSeeder extends Seeder
{
    public function run(): void
    {
        $mahasiswas = User::where('role', 'mahasiswa')->get();
        $faker = \Faker\Factory::create('id_ID');

        // Create 50 random patients
        for ($i = 0; $i < 50; $i++) {
            Patient::create([
                'name' => $faker->name,
                'rm_number' => 'RM' . str_pad($i + 1, 3, '0', STR_PAD_LEFT),
                'gender' => $faker->randomElement(['L', 'P']),
                'age' => $faker->numberBetween(18, 80),
                'address' => $faker->address,
                'created_by' => $mahasiswas->random()->id,
                'created_at' => $faker->dateTimeBetween('-1 year', 'now'),
                'updated_at' => now(),
            ]);
        }
    }
}
