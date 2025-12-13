<?php

namespace Database\Seeders;

use App\Models\Documentation;
use App\Models\Form;
use Illuminate\Database\Seeder;

class DocumentationSeeder extends Seeder
{
    public function run(): void
    {
        $forms = Form::all();
        $faker = \Faker\Factory::create('id_ID');

        foreach ($forms as $form) {
            // 30% chance for a form to have documentation
            if (rand(1, 100) <= 30) {
                // Determine number of docs
                $numDocs = rand(1, 3);
                
                for ($i = 0; $i < $numDocs; $i++) {
                    Documentation::create([
                        'form_id' => $form->id,
                        'file_path' => 'documentations/' . $faker->uuid . '.' . $faker->randomElement(['pdf', 'jpg', 'png', 'docx']),
                        'type' => $faker->randomElement(['materi', 'foto', 'lainnya']),
                        'created_at' => $faker->dateTimeBetween($form->created_at, 'now'),
                        'updated_at' => now(),
                    ]);
                }
            }
        }
        
        $this->command->info('Random documentation records created successfully!');
    }
}
