<?php

namespace App\Filament\Resources;



use App\Filament\Resources\MataKuliahResource\Pages\ListSemesters;
use App\Filament\Resources\MataKuliahResource\Pages\CreateSemester;
use App\Filament\Resources\SemsetResource\Pages\EditSemester;
use App\Filament\Resources\SemesterResource\Pages;
use App\Filament\Resources\SemesterResource\RelationManagers;
use App\Models\Semester;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SemesterResource extends Resource
{
    protected static ?string $model = Semester::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationLabel = 'Semester';
    protected static ?string $modelLabel = 'Semester';
    protected static ?string $pluralModelLabel = 'Semester';
    public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('nama') // Sesuai tabelmu 'nama'
                ->label('Nama Semester')
                ->placeholder('Contoh: Semester Ganjil 2024')
                ->required(),
            Forms\Components\DatePicker::make('tanggal_mulai'),
            Forms\Components\DatePicker::make('tanggal_selesai'),
            Forms\Components\Toggle::make('is_active')->label('Aktif?'),
        ]);
}

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nama')
                    ->label('Nama Semester')
                    ->searchable(),
                Tables\Columns\TextColumn::make('tanggal_mulai')
                    ->label('Tanggal Mulai'),
                Tables\Columns\TextColumn::make('tanggal_selesai')
                    ->label('Tanggal Selesai'),
                Tables\Columns\TextColumn::make('is_active')
                    ->label('Aktif')
                    ->badge()
                    ->color('success')
                    ->alignCenter(),
            ])
            ->filters([
                //
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
            'index' => Pages\ListSemesters::route('/'),
            'create' => Pages\CreateSemester::route('/create'),
            'edit' => Pages\EditSemester::route('/{record}/edit'),
        ];
    }
}
