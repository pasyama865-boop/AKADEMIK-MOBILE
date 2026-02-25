<?php

namespace App\Filament\Resources\MahasiswaResource\Pages;

use App\Filament\Resources\MahasiswaResource;
use Filament\Resources\Pages\CreateRecord;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class CreateMahasiswa extends CreateRecord
{
    protected static string $resource = MahasiswaResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // 1. Buat User Baru role Mahasiswa
        $user = User::create([
            'name' => $data['nama_user'],
            'email' => $data['email_user'],
            'password' => Hash::make($data['password_user']),
            'role' => 'mahasiswa', 
        ]);

        // 2. Sambungkan ID
        $data['user_id'] = $user->id;

        // 3. Bersihkan data
        unset($data['nama_user']);
        unset($data['email_user']);
        unset($data['password_user']);

        return $data;
    }
}
