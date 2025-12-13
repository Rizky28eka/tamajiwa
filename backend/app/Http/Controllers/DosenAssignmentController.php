<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class DosenAssignmentController extends Controller
{
    /**
     * Assign a lecturer to the authenticated student.
     */
    public function assignDosen(Request $request)
    {
        $user = $request->user();

        // Validate that the user is a student
        if ($user->role !== 'mahasiswa') {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_ROLE',
                    'message' => 'Only students can assign lecturers',
                    'required_role' => 'mahasiswa',
                ],
            ], 403);
        }

        // Validate the request
        $validated = $request->validate([
            'dosen_id' => 'required|exists:users,id,role,dosen',
            'dosen_assignment_note' => 'nullable|string|max:1000',
        ]);

        $dosen = User::find($validated['dosen_id']);

        // Check if student has already selected a lecturer
        if ($user->dosen_id !== null) {
            return response()->json([
                'error' => [
                    'code' => 'DOSEN_ALREADY_ASSIGNED',
                    'message' => 'You have already assigned a lecturer. Assignment can only be done once.',
                    'current_dosen_id' => $user->dosen_id,
                ],
            ], 400);
        }

        // Check if the selected lecturer already has this student assigned
        // (Additional check to prevent duplicate assignments)
        if ($dosen->id === $user->dosen_id) {
            return response()->json([
                'error' => [
                    'code' => 'DOSEN_ALREADY_SELECTED',
                    'message' => 'You have already selected this lecturer',
                ],
            ], 400);
        }

        // Perform the assignment
        $user->update([
            'dosen_id' => $dosen->id,
            'dosen_selected_at' => now(),
            'dosen_assignment_note' => $validated['dosen_assignment_note'] ?? null,
        ]);

        // Load the associated dosen for the response
        $user->load('dosen');

        return response()->json([
            'message' => 'Lecturer assigned successfully',
            'user' => $user->load('dosen'),
        ], 200);
    }

    /**
     * Get the assigned lecturer for the authenticated student.
     */
    public function getAssignedDosen(Request $request)
    {
        $user = $request->user();

        // Check if user has assigned a lecturer
        if ($user->dosen_id === null) {
            return response()->json([
                'message' => 'No lecturer assigned yet',
                'assigned' => false,
            ], 200);
        }

        $user->load('dosen');

        return response()->json([
            'message' => 'Lecturer assignment retrieved successfully',
            'assigned' => true,
            'user' => $user->load('dosen'),
        ], 200);
    }

    /**
     * Allow a lecturer to see their assigned students.
     */
    public function getAssignedStudents(Request $request)
    {
        $dosen = $request->user();

        // Validate that the user is a lecturer
        if ($dosen->role !== 'dosen') {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_ROLE',
                    'message' => 'Only lecturers can view assigned students',
                    'required_role' => 'dosen',
                ],
            ], 403);
        }

        $students = User::where('dosen_id', $dosen->id)->get();

        return response()->json([
            'message' => 'Assigned students retrieved successfully',
            'students' => $students->load('assignedStudentForms'),
        ], 200);
    }

    /**
     * Remove lecturer assignment (for admin/lecturer use only)
     */
    public function removeAssignment(Request $request, $user_id)
    {
        $currentUser = $request->user();

        // Only allow if the current user is admin or the assigned lecturer
        $user = User::findOrFail($user_id);

        if ($currentUser->role !== 'admin' &&
            ($currentUser->role !== 'dosen' || $currentUser->id !== $user->dosen_id)) {
            return response()->json([
                'error' => [
                    'code' => 'UNAUTHORIZED',
                    'message' => 'You are not authorized to remove this assignment',
                ],
            ], 403);
        }

        $user->update([
            'dosen_id' => null,
            'dosen_selected_at' => null,
            'dosen_assignment_note' => null,
        ]);

        return response()->json([
            'message' => 'Lecturer assignment removed successfully',
            'user' => $user,
        ], 200);
    }
}
