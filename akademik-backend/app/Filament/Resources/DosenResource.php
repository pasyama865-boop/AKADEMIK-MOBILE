<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DosenResource\Pages;
use App\Filament\Resources\DosenResource\RelationManagers;
use App\Models\Dosen;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class DosenResource extends Resource
{
    protected static ?string $model = Dosen::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationLabel = 'Dosen';
    protected static ?string $modelLabel = 'Dosen';
    protected static ?string $pluralModelLabel = 'Dosen';

    public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\Section::make('Informasi Akun Login')
                ->description('Data ini akan otomatis membuat User baru.')
                ->schema([
                    // 1. NAMA
                    Forms\Components\TextInput::make('user_id')
                        ->label('Nama Lengkap')
                        ->required(),


                    // 2. EMAIL
                    Forms\Components\TextInput::make('email_user')
                        ->label('Email Login')
                        ->email()
                        ->required()
                        ->unique(table: 'users', column: 'email'),

                    // 3. PASSWORD
                    Forms\Components\TextInput::make('password_user')
                        ->label('Password')
                        ->password()
                        ->required(),
                ])->columns(2),

            Forms\Components\Section::make('Profil Dosen')
                ->schema([
                    Forms\Components\TextInput::make('nip')
                        ->label('NIP')
                        ->required()
                        ->unique(),

                    Forms\Components\TextInput::make('gelar'),
                    Forms\Components\TextInput::make('no_hp'),
                    // Sembunyikan user_id
                    Forms\Components\Hidden::make('user_id'),
                ])->columns(2),
        ]);
}

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nip')
                    ->label('NIP')
                    ->sortable()
                    ->searchable()
                    ->badge()
                    ->color(color: 'success')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Nama Dosen')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('gelar')
                    ->label('Gelar'),
                Tables\Columns\TextColumn::make('no_hp')
                    ->label('NO HP')
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
            'index' => Pages\ListDosens::route('/'),
            'create' => Pages\CreateDosen::route('/create'),
            'edit' => Pages\EditDosen::route('/{record}/edit'),
        ];
    }
}
