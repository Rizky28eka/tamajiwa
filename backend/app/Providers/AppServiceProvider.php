<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // API tanpa halaman web: tautan reset mengarah ke URL aplikasi/situs yang menangani token.
        ResetPassword::createUrlUsing(fn ($user, string $token) => rtrim(config('app.url'), '/').'/reset-password?token='.$token.'&email='.urlencode($user->email));
        //
    }
}
