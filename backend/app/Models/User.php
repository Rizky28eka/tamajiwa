<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'username',
        'email',
        'phone_number',
        'profile_photo',
        'password',
        'role',
        'dosen_id',
        'dosen_selected_at',
        'dosen_assignment_note',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'username_changed_at' => 'datetime',
            'phone_changed_at' => 'datetime',
            'dosen_selected_at' => 'datetime',
        ];
    }

    /**
     * Get the lecturer assigned to this student.
     */
    public function dosen()
    {
        return $this->belongsTo(User::class, 'dosen_id');
    }

    /**
     * Get the students assigned to this lecturer.
     */
    public function assignedStudents()
    {
        return $this->hasMany(User::class, 'dosen_id');
    }

    /**
     * Get forms created by students assigned to this lecturer.
     */
    public function assignedStudentForms()
    {
        return $this->hasManyThrough(Form::class, User::class, 'dosen_id', 'user_id', 'id', 'id');
    }
}
