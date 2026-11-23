<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'dosen',
        ]);

        User::create([
            'name' => 'Student User',
            'email' => 'student@example.com',
            'password' => Hash::make('password'),
            'role' => 'mahasiswa',
        ]);

        // Create 5 Additional Dosens
        $dosenIds = [];
        for ($i = 1; $i <= 5; $i++) {
            $dosenIds[] = User::create([
                'name' => "Dosen $i",
                'email' => "dosen$i@example.com",
                'password' => Hash::make('password'),
                'role' => 'dosen',
            ])->id;
        }

        // Create 10 Additional Mahasiswas, each assigned to a dosen so the
        // lecturer screens (students, forms to review) have data in demos.
        // Mahasiswa 1 and 6 belong to Dosen 1, and so on.
        for ($i = 1; $i <= 10; $i++) {
            User::create([
                'name' => "Mahasiswa $i",
                'email' => "mahasiswa$i@example.com",
                'password' => Hash::make('password'),
                'role' => 'mahasiswa',
                'dosen_id' => $dosenIds[($i - 1) % count($dosenIds)],
                'dosen_selected_at' => now(),
            ]);
        }
}
}
