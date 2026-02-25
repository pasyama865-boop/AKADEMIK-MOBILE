<?php

namespace App\Filament\Resources;

use App\Filament\Resources\JadwalResource\Pages\EditJadwal;
use App\Filament\Resources\JadwalResource\Pages\CreateJadwal;
use App\Filament\Resources\JadwalResource\Pages\ListJadwals;
use App\Models\Jadwal;
use App\Models\Dosen;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Section;
use Filament\Support\Colors\Color;

class JadwalResource extends Resource
{
    protected static ?string $model = Jadwal::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationLabel = 'Jadwal Kuliah';
    protected static ?string $modelLabel = 'Jadwal Kuliah';
    protected static ?string $pluralModelLabel = 'Jadwal Kuliah';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Informasi Akademik')
                    ->schema([
                        // 1. MATA KULIAH
                        Select::make('mata_kuliah_id')
                            ->label('Mata Kuliah')
                            ->relationship('mataKuliah', 'nama_matkul')
                            ->searchable()
                            ->preload()
                            ->required(),

                        // 2. DOSEN
                        Select::make('dosen_id')
                            ->label('Dosen')
                            ->options(function () {
                                return Dosen::with('user')
                                ->get()->mapWithKeys(function ($dosen) {
                                    return [$dosen->user->name, $dosen->user->id];
                                });

                            }
                            )
                            ->searchable()
                            ->required(),

                        // 3. SEMESTER
                        Select::make('semester_id')
                            ->label('Semester')
                            ->relationship('semester', 'nama')
                            ->searchable()
                            ->preload()
                            ->required(),

                        TextInput::make('kuota')
                            ->numeric()
                            ->default(40)
                            ->required(),
                    ])->columns(2),

                Section::make('Waktu & Tempat')
                    ->schema([
                        Select::make('hari')
                            ->options([
                                'Senin' => 'Senin',
                                'Selasa' => 'Selasa',
                                'Rabu' => 'Rabu',
                                'Kamis' => 'Kamis',
                                'Jumat' => 'Jumat',
                                'Sabtu' => 'Sabtu',
                            ])->required(),

                        // 4. RUANGAN
                        Select::make('ruangan_id')
                            ->label('Ruangan')
                            ->relationship('ruangan', 'nama')
                            ->searchable()
                            ->preload()
                            ->required(),

                        TimePicker::make('jam_mulai')->required(),
                        TimePicker::make('jam_selesai')->required(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('mataKuliah.nama_matkul')
                    ->label('Mata Kuliah')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('dosen.name') 
                    ->label('Dosen Pengajar')
                    ->sortable()
                    ->searchable(),

                // Menampilkan Semester di Tabel
                Tables\Columns\TextColumn::make('semester.nama')
                    ->label('Semester')
                    ->sortable(),

                Tables\Columns\TextColumn::make('hari')
                    ->badge()
                    ->color('success'),

                Tables\Columns\TextColumn::make('jam_mulai')
                    ->label('Waktu')
                    ->formatStateUsing(fn ($state, $record) => "$state - {$record->jam_selesai}"),

                Tables\Columns\TextColumn::make('ruangan.nama')
                    ->label('Ruangan'),
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
            'index' => ListJadwals::route('/'),
            'create' => CreateJadwal::route('/create'),
            'edit' => EditJadwal::route('/{record}/edit'),
        ];
    }
}
