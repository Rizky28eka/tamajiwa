<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Laravel\Sanctum\Sanctum;

class ApiEndpointsTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    public function test_register_successful()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
            'role' => 'mahasiswa',
        ]);

        $response->assertStatus(201)
                 ->assertJsonStructure(['user', 'token']);
        
        $this->assertDatabaseHas('users', ['email' => 'test@example.com', 'role' => 'mahasiswa']);
    }

    public function test_login_successful()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
            'role' => 'mahasiswa',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['user', 'token']);
    }

    public function test_mahasiswa_can_create_patient()
    {
        $user = User::factory()->create(['role' => 'mahasiswa']);
        
        Sanctum::actingAs($user, ['*']);

        $patientData = [
            'name' => 'John Doe',
            'gender' => 'L',
            'age' => 30,
            'address' => '123 Main St',
            'rm_number' => 'RM001',
        ];

        $response = $this->postJson('/api/patients', $patientData);

        $response->assertStatus(201)
                 ->assertJson(['message' => 'Patient created successfully']);
        
        $this->assertDatabaseHas('patients', ['rm_number' => 'RM001', 'created_by' => $user->id]);
    }

    public function test_dosen_cannot_create_patient()
    {
        $user = User::factory()->create(['role' => 'dosen']);
        
        Sanctum::actingAs($user, ['*']);

        $patientData = [
            'name' => 'John Doe',
            'gender' => 'L',
            'age' => 30,
            'address' => '123 Main St',
            'rm_number' => 'RM002',
        ];

        $response = $this->postJson('/api/patients', $patientData);

        $response->assertStatus(403);
    }

    public function test_mahasiswa_can_view_own_patients()
    {
        $user = User::factory()->create(['role' => 'mahasiswa']);
        $otherUser = User::factory()->create(['role' => 'mahasiswa']);
        
        Sanctum::actingAs($user, ['*']);

        Patient::factory()->create(['created_by' => $user->id]);
        Patient::factory()->create(['created_by' => $otherUser->id]);

        $response = $this->getJson('/api/patients');

        $response->assertStatus(200)
                 ->assertJsonCount(1, 'data'); // Assuming pagination wraps in data
    }

    public function test_user_profile_endpoint()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user, ['*']);

        $response = $this->getJson('/api/user/profile');

        $response->assertStatus(200)
                 ->assertJson(['email' => $user->email]);
    }
}
