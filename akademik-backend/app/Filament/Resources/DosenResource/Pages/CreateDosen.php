<?php

namespace App\Filament\Resources\DosenResource\Pages;

use App\Filament\Resources\DosenResource;
use Filament\Resources\Pages\CreateRecord;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\Model;

class CreateDosen extends CreateRecord
{
    protected static string $resource = DosenResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // 1. Buat User Baru secara manual
        $user = User::create([
            'name' => $data['user_id'],
            'email' => $data['email_user'],
            'password' => Hash::make($data['password_user']),
            'role' => 'dosen',
        ]);

        // 2. Ambil ID User yang baru dibuat, masukkan ke data Dosen
        $data['user_id'] = $user->id;

        // 3. Hapus data akun dari array 
        unset($data['nama_user']);
        unset($data['email_user']);
        unset($data['password_user']);

        return $data;
    }
}
