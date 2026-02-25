<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MataKuliahResource\Pages\CreateMataKuliah;
use App\Filament\Resources\MataKuliahResource\Pages\EditMataKuliah;
use App\Filament\Resources\MataKuliahResource\Pages\ListMataKuliahs;
use App\Models\MataKuliah;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Section;

class MataKuliahResource extends Resource
{
    protected static ?string $model = MataKuliah::class;

    protected static ?string $navigationIcon = 'heroicon-o-book-open';

    protected static ?string $navigationLabel = 'Mata Kuliah';
    protected static ?string $modelLabel = 'Mata Kuliah';
    protected static ?string $pluralModelLabel = 'Mata Kuliah';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Informasi Mata Kuliah')
                    ->description('Masukkan detail mata kuliah baru.')
                    ->schema([
                        // 1. Kode Matkul
                        TextInput::make('kode_matkul')
                            ->label('Kode Mata Kuliah')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(10),

                        // 2. Nama Matkul
                        TextInput::make('nama_matkul')
                            ->label('Nama Mata Kuliah')
                            ->required()
                            ->maxLength(255),

                        // 3. SKS
                        TextInput::make('sks')
                            ->label('SKS')
                            ->numeric()
                            ->required()
                            ->maxValue(6)
                            ->minValue(1),

                        // 4. Semester Paket (Contoh: Ini matkul semester 1, 2, dst)
                        TextInput::make('semester_paket')
                            ->label('Semester Paket')
                            ->numeric()
                            ->required()
                            ->maxValue(8)
                            ->minValue(1),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('kode_matkul')
                    ->label('Kode')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('nama_matkul')
                    ->label('Nama Mata Kuliah')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('sks')
                    ->label('SKS')
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('semester_paket')
                    ->label('Semester')
                    ->alignCenter()
                    ->color('success')
                    ->badge(),
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
            'index' => ListMataKuliahs::route('/'),
            'create' => CreateMataKuliah::route('/create'),
            'edit' => EditMataKuliah::route('/{record}/edit'),
        ];
    }
}
