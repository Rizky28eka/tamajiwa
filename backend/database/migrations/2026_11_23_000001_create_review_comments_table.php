<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Komentar review per bagian formulir.
     */
    public function up(): void
    {
        Schema::create('review_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('form_id')->constrained()->cascadeOnDelete();
            $table->foreignId('reviewer_id')->constrained('users')->cascadeOnDelete();
            // Kunci bagian formulir, mis. "section_1" atau "renpra". Null = komentar umum.
            $table->string('section')->nullable();
            $table->text('comment');
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['form_id', 'resolved_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('review_comments');
    }
};
