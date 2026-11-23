<?php

namespace Tests\Feature;

use App\Models\Form;
use App\Models\Patient;
use App\Models\ReviewComment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ReviewCommentTest extends TestCase
{
    use RefreshDatabase;

    private function assign(User $student, User $dosen): void
    {
        $student->update(['dosen_id' => $dosen->id]);
    }

    private function submittedForm(User $student): Form
    {
        $patient = Patient::factory()->create(['created_by' => $student->id]);

        return Form::factory()->create([
            'type' => 'pengkajian',
            'user_id' => $student->id,
            'patient_id' => $patient->id,
            'status' => 'submitted',
        ]);
    }

    public function test_dosen_can_request_revision_with_section_comments(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $this->assign($student, $dosen);
        $form = $this->submittedForm($student);

        Sanctum::actingAs($dosen, ['*']);

        $this->postJson("/api/forms/{$form->id}/review", [
            'status' => 'revised',
            'comment' => 'Mohon dilengkapi.',
            'comments' => [
                ['section' => 'section_1', 'comment' => 'Identitas belum lengkap'],
                ['section' => 'renpra', 'comment' => 'Rasional kurang jelas'],
            ],
        ])->assertOk();

        $this->assertDatabaseHas('forms', ['id' => $form->id, 'status' => 'revised']);
        $this->assertDatabaseCount('review_comments', 2);
        $this->assertDatabaseHas('review_comments', [
            'form_id' => $form->id,
            'section' => 'renpra',
            'reviewer_id' => $dosen->id,
        ]);
    }

    public function test_student_sees_comments_when_opening_form(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $form = $this->submittedForm($student);
        ReviewComment::create([
            'form_id' => $form->id,
            'reviewer_id' => $dosen->id,
            'section' => 'section_1',
            'comment' => 'Perbaiki',
        ]);

        Sanctum::actingAs($student, ['*']);

        $this->getJson("/api/forms/{$form->id}")
            ->assertOk()
            ->assertJsonPath('review_comments.0.comment', 'Perbaiki')
            ->assertJsonPath('review_comments.0.reviewer.name', $dosen->name);
    }

    public function test_owner_can_resolve_and_reopen_a_comment(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $form = $this->submittedForm($student);
        $comment = ReviewComment::create([
            'form_id' => $form->id,
            'reviewer_id' => $dosen->id,
            'section' => null,
            'comment' => 'Umum',
        ]);

        Sanctum::actingAs($student, ['*']);

        $this->postJson("/api/review-comments/{$comment->id}/resolve")
            ->assertOk()
            ->assertJsonPath('resolved_at', fn ($v) => $v !== null);

        $this->postJson("/api/review-comments/{$comment->id}/resolve")
            ->assertOk()
            ->assertJsonPath('resolved_at', null);
    }

    public function test_other_student_cannot_resolve_comment(): void
    {
        $owner = User::factory()->create(['role' => 'mahasiswa']);
        $other = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $form = $this->submittedForm($owner);
        $comment = ReviewComment::create([
            'form_id' => $form->id,
            'reviewer_id' => $dosen->id,
            'comment' => 'Umum',
        ]);

        Sanctum::actingAs($other, ['*']);

        $this->postJson("/api/review-comments/{$comment->id}/resolve")->assertForbidden();
        $this->assertDatabaseHas('review_comments', ['id' => $comment->id, 'resolved_at' => null]);
    }

    public function test_student_cannot_post_review(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $form = $this->submittedForm($student);

        Sanctum::actingAs($student, ['*']);

        $this->postJson("/api/forms/{$form->id}/review", [
            'status' => 'approved',
            'comments' => [['section' => 'x', 'comment' => 'y']],
        ])->assertForbidden();

        $this->assertDatabaseCount('review_comments', 0);
    }

    public function test_empty_section_comment_is_rejected(): void
    {
        $student = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $this->assign($student, $dosen);
        $form = $this->submittedForm($student);

        Sanctum::actingAs($dosen, ['*']);

        $this->postJson("/api/forms/{$form->id}/review", [
            'status' => 'revised',
            'comments' => [['section' => 'section_1', 'comment' => '']],
        ])->assertUnprocessable();
    }

    public function test_dosen_cannot_review_unassigned_students_form(): void
    {
        $mine = User::factory()->create(['role' => 'mahasiswa']);
        $stranger = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $this->assign($mine, $dosen);
        $form = $this->submittedForm($stranger);

        Sanctum::actingAs($dosen, ['*']);

        $this->postJson("/api/forms/{$form->id}/review", ['status' => 'approved'])->assertForbidden();
        $this->getJson("/api/forms/{$form->id}")->assertForbidden();
        $this->assertDatabaseHas('forms', ['id' => $form->id, 'status' => 'submitted']);
    }

    public function test_submitted_queue_only_lists_assigned_students(): void
    {
        $mine = User::factory()->create(['role' => 'mahasiswa']);
        $stranger = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $this->assign($mine, $dosen);
        $ownForm = $this->submittedForm($mine);
        $this->submittedForm($stranger);

        Sanctum::actingAs($dosen, ['*']);

        $res = $this->getJson('/api/forms/submitted')->assertOk();
        $this->assertSame([$ownForm->id], collect($res->json('data'))->pluck('id')->all());
    }

    public function test_forms_index_filters_by_status_and_student(): void
    {
        $a = User::factory()->create(['role' => 'mahasiswa']);
        $b = User::factory()->create(['role' => 'mahasiswa']);
        $dosen = User::factory()->create(['role' => 'dosen']);
        $this->assign($a, $dosen);
        $this->assign($b, $dosen);
        $formA = $this->submittedForm($a);
        $this->submittedForm($b);
        Form::factory()->create([
            'type' => 'sap', 'user_id' => $a->id,
            'patient_id' => $formA->patient_id, 'status' => 'approved',
        ]);

        Sanctum::actingAs($dosen, ['*']);

        $byStatus = $this->getJson('/api/forms?status=approved')->assertOk();
        $this->assertCount(1, $byStatus->json('data'));

        $byStudent = $this->getJson("/api/forms?user_id={$a->id}")->assertOk();
        $this->assertCount(2, $byStudent->json('data'));
    }
}
