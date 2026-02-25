<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KrsResource\Pages;
use App\Models\Krs;
use App\Models\Jadwal;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Select;

class KrsResource extends Resource
{
    protected static ?string $model = Krs::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-check';

    protected static ?string $navigationLabel = 'KRS Mahasiswa';
    protected static ?string $modelLabel = 'KRS Mahasiswa';
    protected static ?string $pluralModelLabel= 'KRS Mahasiswa';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                // 1. Pilih Mahasiswa
                Select::make('mahasiswa_id')
                    ->label('Mahasiswa')
                    ->relationship('mahasiswa', 'nim')
                    ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->nim} - {$record->user->name}")
                    ->searchable()
                    ->preload()
                    ->required(),

                // 2. Pilih Jadwal
                Select::make('jadwal_id')
                    ->label('Pilih Jadwal Kuliah')
                    ->options(function () {
                        return Jadwal::with('mataKuliah')->get()->mapWithKeys(function ($jadwal) {
                            return [
                                $jadwal->id => $jadwal->mataKuliah->nama_matkul . ' - ' . $jadwal->hari . ' (' . $jadwal->jam_mulai . ')',
                            ];
                        });
                    })
                    ->searchable()
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                // Menampilkan NIM
                Tables\Columns\TextColumn::make('mahasiswa.nim')
                    ->label('NIM')
                    ->sortable()
                    ->searchable()
                    ->badge()
                    ->color(color: 'success')
                    ->alignCenter(),

                // Menampilkan Nama Mahasiswa
                Tables\Columns\TextColumn::make('mahasiswa.user.name')
                    ->label('Nama Mahasiswa')
                    ->sortable(),

                // Menampilkan Matkul yang diambil
                Tables\Columns\TextColumn::make('jadwal.mataKuliah.nama_matkul')
                    ->label('Mata Kuliah')
                    ->sortable(),

                // Menampilkan Hari
                Tables\Columns\TextColumn::make('jadwal.hari')
                    ->label('Hari'),

                // Menampilkan Jam
                Tables\Columns\TextColumn::make('jadwal.jam_mulai')
                    ->label('Jam'),
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
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListKrs::route('/'),
            'create' => Pages\CreateKrs::route('/create'),
            'edit' => Pages\EditKrs::route('/{record}/edit'),
        ];
    }
}
