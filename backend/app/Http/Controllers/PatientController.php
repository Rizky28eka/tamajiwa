<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PatientController extends Controller
{
    /**
     * Display a listing of the patients.
     */
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'dosen') {
            // For lecturers, get patients created by their assigned students
            $studentIds = User::where('dosen_id', $user->id)->pluck('id');
            $patients = Patient::whereIn('created_by', $studentIds)
                ->orderBy('created_at', 'desc')
                ->paginate(10);
        } else {
            // For students, get only their own patients
            $patients = Patient::where('created_by', $user->id)
                ->orderBy('created_at', 'desc')
                ->paginate(10);
        }

        return response()->json($patients);
    }

    /**
     * Store a newly created patient in storage.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        // Only students can create patients
        if ($user->role !== 'mahasiswa') {
            return response()->json([
                'message' => 'Only students can create patients',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'gender' => 'required|in:L,P',
            'age' => 'required|integer|min:0|max:150',
            'address' => 'required|string|max:500',
            'rm_number' => 'required|string|max:50|unique:patients,rm_number',
        ]);

        $validated['created_by'] = $user->id;

        $patient = Patient::create($validated);

        return response()->json([
            'message' => 'Patient created successfully',
            'patient' => $patient,
        ], 201);
    }

    /**
     * Display the specified patient.
     */
    public function show(Request $request, Patient $patient)
    {
        $user = $request->user();

        // Check if the patient is created by the current user
        if ($patient->created_by === $user->id) {
            return response()->json($patient);
        }

        // Check if the user is a lecturer assigned to the patient's creator
        if ($user->role === 'dosen') {
            $patientCreator = User::find($patient->created_by);
            if ($patientCreator && $patientCreator->dosen_id === $user->id) {
                return response()->json($patient);
            }
        }

        return response()->json([
            'message' => 'Unauthorized',
        ], 403);
    }

    /**
     * Update the specified patient in storage.
     */
    public function update(Request $request, Patient $patient)
    {
        $user = $request->user();

        // Only students can update their own patients
        if ($patient->created_by !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        // Prevent lecturers from updating (only students can update)
        if ($user->role !== 'mahasiswa') {
            return response()->json([
                'message' => 'Only students can update patients',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'gender' => 'sometimes|required|in:L,P',
            'age' => 'sometimes|required|integer|min:0|max:150',
            'address' => 'sometimes|required|string|max:500',
            'rm_number' => [
                'sometimes',
                'required',
                'string',
                'max:50',
                Rule::unique('patients')->ignore($patient->id),
            ],
        ]);

        $patient->update($validated);

        return response()->json([
            'message' => 'Patient updated successfully',
            'patient' => $patient,
        ]);
    }

    /**
     * Remove the specified patient from storage.
     */
    public function destroy(Request $request, Patient $patient)
    {
        $user = $request->user();

        // Only students can delete their own patients
        if ($patient->created_by !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        // Prevent lecturers from deleting (only students can delete)
        if ($user->role !== 'mahasiswa') {
            return response()->json([
                'message' => 'Only students can delete patients',
            ], 403);
        }

        $patient->delete();

        return response()->json([
            'message' => 'Patient deleted successfully',
        ]);
    }
}
