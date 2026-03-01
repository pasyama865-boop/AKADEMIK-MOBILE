<?php

namespace App\Http\Middleware;

use App\Models\AuditLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuditAdminAction
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Hanya catat aksi manipulasi data (POST, PUT, DELETE)
        if (in_array($request->method(), ['POST', 'PUT', 'DELETE']) && $response->isSuccessful()) {
            $user = $request->user();
            
            if ($user && $user->role === 'admin') {
                $action = strtoupper($request->method()) . '_' . strtoupper(str_replace('/', '_', trim($request->path(), '/')));
                
                AuditLog::create([
                    'user_id'     => $user->id,
                    'action'      => $action,
                    'description' => "Admin {$user->name} melakukan {$request->method()} pada {$request->path()}",
                    'ip_address'  => $request->ip(),
                ]);
            }
        }

        return $response;
    }
}
