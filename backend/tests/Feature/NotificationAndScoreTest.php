<?php

namespace Tests\Feature;

use App\Models\Form;
use App\Models\Patient;
use App\Models\User;
use App\Models\UserNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationAndScoreTest extends TestCase
{
    use RefreshDatabase;

    private function pair(): array
    {
        $dosen = User::factory()->create(['role' => 'dosen']);
        $student = User::factory()->create(['role' => 'mahasiswa', 'dosen_id' => $dosen->id]);

        return [$dosen, $student];
    }

    private function form(User $student, string $status): Form
    {
        $patient = Patient::factory()->create(['created_by' => $student->id]);

        return Form::factory()->create([
            'type' => 'sap', 'user_id' => $student->id,
            'patient_id' => $patient->id, 'status' => $status,
        ]);
    }

    public function test_submitting_a_form_notifies_the_assigned_dosen(): void
    {
        [$dosen, $student] = $this->pair();
        $form = $this->form($student, 'draft');

        Sanctum::actingAs($student, ['*']);
        $this->putJson("/api/forms/{$form->id}", ['status' => 'submitted'])->assertOk();

        $this->assertDatabaseHas('user_notifications', [
            'user_id' => $dosen->id, 'type' => 'form_submitted', 'form_id' => $form->id,
        ]);
    }

    public function test_resaving_an_already_submitted_form_does_not_notify_again(): void
    {
        [$dosen, $student] = $this->pair();
        $form = $this->form($student, 'submitted');

        Sanctum::actingAs($student, ['*']);
        $this->putJson("/api/forms/{$form->id}", ['status' => 'submitted'])->assertOk();

        $this->assertDatabaseCount('user_notifications', 0);
    }

    public function test_student_without_dosen_submits_without_error(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $form = $this->form($student, 'draft');

        Sanctum::actingAs($student, ['*']);
        $this->putJson("/api/forms/{$form->id}", ['status' => 'submitted'])->assertOk();
        $this->assertDatabaseCount('user_notifications', 0);
    }

    public function test_review_notifies_student_and_stores_score(): void
    {
        [$dosen, $student] = $this->pair();
        $form = $this->form($student, 'submitted');

        Sanctum::actingAs($dosen, ['*']);
        $this->postJson("/api/forms/{$form->id}/review", ['status' => 'approved', 'score' => 88])->assertOk();

        $this->assertDatabaseHas('forms', ['id' => $form->id, 'status' => 'approved', 'score' => 88]);
        $this->assertDatabaseHas('user_notifications', [
            'user_id' => $student->id, 'type' => 'form_approved',
        ]);
    }

    public function test_score_out_of_range_is_rejected(): void
    {
        [$dosen, $student] = $this->pair();
        $form = $this->form($student, 'submitted');

        Sanctum::actingAs($dosen, ['*']);
        $this->postJson("/api/forms/{$form->id}/review", ['status' => 'approved', 'score' => 101])->assertUnprocessable();
        $this->assertDatabaseHas('forms', ['id' => $form->id, 'status' => 'submitted']);
    }

    public function test_student_cannot_set_own_score(): void
    {
        [$dosen, $student] = $this->pair();
        $form = $this->form($student, 'draft');

        Sanctum::actingAs($student, ['*']);
        $this->putJson("/api/forms/{$form->id}", ['status' => 'submitted', 'score' => 100])->assertOk();

        $this->assertNull($form->fresh()->score);
    }

    public function test_notifications_list_count_and_read_flow(): void
    {
        [$dosen, $student] = $this->pair();
        UserNotification::create(['user_id' => $student->id, 'type' => 'form_revised', 'title' => 'A']);
        $other = UserNotification::create(['user_id' => $dosen->id, 'type' => 'form_submitted', 'title' => 'B']);
        $mine = UserNotification::create(['user_id' => $student->id, 'type' => 'form_approved', 'title' => 'C']);

        Sanctum::actingAs($student, ['*']);

        $this->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonPath('unread_count', 2)
            ->assertJsonCount(2, 'data');

        $this->postJson("/api/notifications/{$mine->id}/read")->assertOk();
        $this->getJson('/api/notifications')->assertJsonPath('unread_count', 1);

        // Tidak bisa menyentuh notifikasi orang lain
        $this->postJson("/api/notifications/{$other->id}/read")->assertNotFound();
        $this->assertNull($other->fresh()->read_at);

        $this->postJson('/api/notifications/read-all')->assertOk();
        $this->getJson('/api/notifications')->assertJsonPath('unread_count', 0);
        // read-all tidak menyentuh milik orang lain
        $this->assertNull($other->fresh()->read_at);
    }
}
