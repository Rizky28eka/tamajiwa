<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Handle user registration
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|string|in:mahasiswa,dosen',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'dosen_id' => $user->dosen_id,
                'dosen_selected_at' => $user->dosen_selected_at ? $user->dosen_selected_at->toDateTimeString() : null,
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    /**
     * Handle user login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'dosen_id' => $user->dosen_id,
                'dosen_selected_at' => $user->dosen_selected_at ? $user->dosen_selected_at->toDateTimeString() : null,
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * Handle user logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out',
        ]);
    }

    /**
     * Get user profile
     */
    public function getUserProfile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'username' => $user->username,
            'phone_number' => $user->phone_number,
            'profile_photo' => $user->profile_photo ? asset('storage/'.$user->profile_photo) : null,
            'email' => $user->email,
            'role' => $user->role,
            'username_changed_at' => $user->username_changed_at ? $user->username_changed_at->toDateTimeString() : null,
            'phone_changed_at' => $user->phone_changed_at ? $user->phone_changed_at->toDateTimeString() : null,
            'dosen_id' => $user->dosen_id,
            'dosen_selected_at' => $user->dosen_selected_at ? $user->dosen_selected_at->toDateTimeString() : null,
        ]);
    }

    /**
     * Update user profile
     */
    public function updateUserProfile(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'username' => 'sometimes|string|max:255|unique:users,username,'.$request->user()->id,
            'phone_number' => 'sometimes|string|max:20|unique:users,phone_number,'.$request->user()->id,
            'password' => 'sometimes|string|min:8|confirmed',
            'profile_photo' => 'sometimes|file|mimes:jpeg,png,jpg,gif,webp|max:5120', // 5MB
        ]);

        $user = $request->user();

        $data = $request->only(['name', 'username', 'phone_number']);
        if ($request->has('password')) {
            $data['password'] = Hash::make($request->password);
        }

        // Handle username change only once
        if ($request->has('username')) {
            if ($user->username_changed_at !== null) {
                return response()->json([
                    'message' => 'Username can only be changed once.',
                ], 403);
            }
            $data['username_changed_at'] = now();
        }

        // Handle phone number change only once
        if ($request->has('phone_number')) {
            if ($user->phone_changed_at !== null) {
                return response()->json([
                    'message' => 'Phone number can only be changed once.',
                ], 403);
            }
            $data['phone_changed_at'] = now();
        }

        // Handle profile photo upload
        if ($request->hasFile('profile_photo')) {
            $file = $request->file('profile_photo');
            $path = $file->store('profiles', 'public');
            $data['profile_photo'] = $path;
        }

        $user->update($data);

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'phone_number' => $user->phone_number,
                'profile_photo' => $user->profile_photo ? asset('storage/'.$user->profile_photo) : null,
                'email' => $user->email,
                'role' => $user->role,
                'username_changed_at' => $user->username_changed_at ? $user->username_changed_at->toDateTimeString() : null,
                'phone_changed_at' => $user->phone_changed_at ? $user->phone_changed_at->toDateTimeString() : null,
            ],
        ]);
    }

    /**
     * Get all dosens
     */
    public function getDosens()
    {
        $dosens = User::where('role', 'dosen')->get();

        return response()->json($dosens);
    }

    /**
     * Update the dosen for a mahasiswa
     */
    public function updateDosen(Request $request)
    {
        $request->validate([
            'dosen_id' => 'required|exists:users,id',
        ]);

        $user = $request->user();

        if ($user->role !== 'mahasiswa') {
            return response()->json(['message' => 'Only mahasiswa can select a dosen.'], 403);
        }

        if ($user->dosen_selected_at !== null) {
            return response()->json(['message' => 'Dosen can only be selected once.'], 403);
        }

        $dosen = User::find($request->dosen_id);

        if (! $dosen || $dosen->role !== 'dosen') {
            return response()->json(['message' => 'Invalid dosen selected.'], 422);
        }

        $user->dosen_id = $request->dosen_id;
        $user->dosen_selected_at = now();
        $user->save();

        return response()->json([
            'message' => 'Dosen updated successfully.',
            'user' => $user,
        ]);
    }
}
