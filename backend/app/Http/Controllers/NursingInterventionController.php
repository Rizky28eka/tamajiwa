<?php

namespace App\Http\Controllers;

use App\Models\NursingIntervention;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NursingInterventionController extends Controller
{
    /**
     * Display a listing of the nursing interventions.
     */
    public function index(Request $request): JsonResponse
    {
        $interventions = NursingIntervention::where('created_by', $request->user()->id)
            ->with('createdBy')
            ->orderBy('name')
            ->get();

        return response()->json($interventions);
    }

    /**
     * Store a newly created nursing intervention in storage.
     */
    public function store(Request $request): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can create interventions',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:nursing_interventions,name',
            'description' => 'nullable|string',
        ]);

        $validated['created_by'] = $request->user()->id;

        $intervention = NursingIntervention::create($validated);

        return response()->json([
            'message' => 'Intervention created successfully',
            'intervention' => $intervention->load('createdBy'),
        ], 201);
    }

    /**
     * Display the specified nursing intervention.
     */
    public function show(Request $request, NursingIntervention $intervention): JsonResponse
    {
        // If user is dosen, only allow access to interventions they created
        if ($request->user()->role === 'dosen' && $intervention->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized: You can only access interventions you created',
            ], 403);
        }

        return response()->json($intervention->load('createdBy'));
    }

    /**
     * Update the specified nursing intervention in storage.
     */
    public function update(Request $request, NursingIntervention $intervention): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can update interventions',
            ], 403);
        }

        // Check if the intervention was created by the current user
        if ($intervention->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized: You can only update interventions you created',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:nursing_interventions,name,'.$intervention->id,
            'description' => 'nullable|string',
        ]);

        $intervention->update($validated);

        return response()->json([
            'message' => 'Intervention updated successfully',
            'intervention' => $intervention->load('createdBy'),
        ]);
    }

    /**
     * Remove the specified nursing intervention from storage.
     */
    public function destroy(Request $request, NursingIntervention $intervention): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can delete interventions',
            ], 403);
        }

        // Check if the intervention was created by the current user
        if ($intervention->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized: You can only delete interventions you created',
            ], 403);
        }

        $intervention->delete();

        return response()->json([
            'message' => 'Intervention deleted successfully',
        ]);
    }
}
