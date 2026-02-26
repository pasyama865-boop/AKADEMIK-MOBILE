<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;


class CheckRole
{    
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        // Periksa apakah user sudah login
        if (!$user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthorized. Silakan login terlebih dahulu.',
            ], 401);
        }

        // Periksa apakah role user termasuk dalam daftar yang diizinkan
        if (!in_array($user->role, $roles)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk fitur ini.',
            ], 403);
        }

        return $next($request);
    }
}
