<?php

namespace Database\Seeders;

use App\Models\Form;
use App\Models\Revision;
use App\Models\User;
use Illuminate\Database\Seeder;

class RevisionSeeder extends Seeder
{
    public function run(): void
    {
        $dosens = User::where('role', 'dosen')->get();
        $forms = Form::where('status', 'submitted')->get();
        $faker = \Faker\Factory::create('id_ID');

        foreach ($forms as $form) {
            // 70% chance of getting a revision
            if (rand(1, 100) <= 70) {
                Revision::create([
                    'form_id' => $form->id,
                    'reviewed_by' => $dosens->isNotEmpty() ? $dosens->random()->id : 1,
                    'comment' => $faker->paragraph,
                    'created_at' => $faker->dateTimeBetween($form->created_at, 'now'),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}
