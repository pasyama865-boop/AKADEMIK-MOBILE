<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MahasiswaResource\Pages;
use App\Filament\Resources\MahasiswaResource\RelationManagers;
use App\Models\Mahasiswa;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MahasiswaResource extends Resource
{
    protected static ?string $model = Mahasiswa::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationLabel = 'Mahasiswa';
    protected static ?string $modelLabel = 'Mahasiswa';
    protected static ?string $pluralModelLabel = 'Mahasiswa';
    public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\Section::make('Akun Mahasiswa')
                ->schema([
                    Forms\Components\TextInput::make('nama_user')
                        ->label('Nama Mahasiswa')
                        ->required(),

                    Forms\Components\TextInput::make('email_user')
                        ->email()
                        ->required()
                        ->unique(table: 'users', column: 'email'),

                    Forms\Components\TextInput::make('password_user')
                        ->password()
                        ->required(),
                ])->columns(2),

            Forms\Components\Section::make('Data Akademik')
                ->schema([
                    Forms\Components\TextInput::make('nim')->required()->unique(),
                    Forms\Components\TextInput::make('jurusan')->required(),
                    Forms\Components\TextInput::make('angkatan')->numeric()->required(),
                    // Sembunyikan user_id
                    Forms\Components\Hidden::make('user_id'),
                ])->columns(2),
        ]);
}

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nim')
                    ->sortable()
                    ->searchable()
                    ->badge()
                    ->color(color: 'success')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Nama Mahasiswa')
                    ->searchable(),
                Tables\Columns\TextColumn::make('jurusan')
                    ->label('Jurusan'),
                Tables\Columns\TextColumn::make('angkatan')
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMahasiswas::route('/'),
            'create' => Pages\CreateMahasiswa::route('/create'),
            'edit' => Pages\EditMahasiswa::route('/{record}/edit'),
        ];
    }
}
