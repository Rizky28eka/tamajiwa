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
        for ($i = 1; $i <= 5; $i++) {
            User::create([
                'name' => "Dosen $i",
                'email' => "dosen$i@example.com",
                'password' => Hash::make('password'),
                'role' => 'dosen',
            ]);
        }

        // Create 10 Additional Mahasiswas
        for ($i = 1; $i <= 10; $i++) {
            User::create([
                'name' => "Mahasiswa $i",
                'email' => "mahasiswa$i@example.com",
                'password' => Hash::make('password'),
                'role' => 'mahasiswa',
            ]);
        }
}
}
