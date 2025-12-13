<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add the required columns to the users table for student-lecturer assignment
        Schema::table('users', function (Blueprint $table) {
            // Add dosen_id to connect mahasiswa to their dosen
            $table->unsignedBigInteger('dosen_id')->nullable()->after('role');
            // Add timestamp to track when dosen was selected (for one-time assignment)
            $table->timestamp('dosen_selected_at')->nullable()->after('dosen_id');
            // Add text field for dosen assignment notes
            $table->text('dosen_assignment_note')->nullable()->after('dosen_selected_at');

            // Add foreign key constraint to reference the dosen user
            $table->foreign('dosen_id')->references('id')->on('users')->onDelete('set null');
        });

        // Add index for better performance on dosen_id
        Schema::table('users', function (Blueprint $table) {
            $table->index('dosen_id');
        });

        // Add index to created_by columns for better query performance only if they don't already exist
        $this->addIndexIfNotExists('nursing_diagnoses', 'created_by');
        $this->addIndexIfNotExists('nursing_interventions', 'created_by');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove indexes and foreign key constraints in reverse order
        // We skip dropping created_by indexes as they might be needed by FK constraints
        // and they were only added optionally in up()

        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['dosen_id']);
            $table->dropIndex(['dosen_id']);
            $table->dropColumn(['dosen_id', 'dosen_selected_at', 'dosen_assignment_note']);
        });
    }

    /**
     * Helper function to add index if it doesn't exist
     */
    private function addIndexIfNotExists($table, $column)
    {
        $indexName = $table.'_'.$column.'_index';

        $connection = Schema::getConnection();
        
        // Check driver to determine the query
        $driver = $connection->getDriverName();
        
        if ($driver === 'sqlite') {
            $exists = DB::select("SELECT name FROM sqlite_master WHERE type='index' AND name=?", [$indexName]);
        } else {
             // MySQL/MariaDB
            $exists = DB::select("SHOW INDEX FROM `{$table}` WHERE Key_name = ?", [$indexName]);
        }

        if (empty($exists)) {
            Schema::table($table, function (Blueprint $table) use ($column) {
                $table->index($column);
            });
        }
    }
};
