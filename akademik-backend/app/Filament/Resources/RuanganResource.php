<?php

namespace App\Filament\Resources;


use App\Filament\Resources\MataKuliahResource\Pages\ListRuangans;
use App\Filament\Resources\MataKuliahResource\Pages\CreateRuangan;
use App\Filament\Resources\MataKuliahResource\Pages\EditRuangan;
use App\Filament\Resources\RuanganResource\Pages;
use App\Filament\Resources\RuanganResource\RelationManagers;
use App\Models\Ruangan;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class RuanganResource extends Resource
{
    protected static ?string $model = Ruangan::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationLabel = 'Ruangan';
    protected static ?string $modelLabel = 'Ruangan';
    protected static ?string $pluralModelLabel = 'Ruangan';

    public static function form(Form $form): Form
{
    return $form
        ->schema([
            Forms\Components\TextInput::make('nama')
                ->label('Nama Ruangan')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('gedung')
                ->label('Lokasi')
                ->maxLength(255),
            Forms\Components\TextInput::make('kapasitas')
                ->label('Kapasitas')
                ->numeric()
                ->required()
                ->maxValue(40)
                ->minValue(1)
        ]);
}

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nama')
                    ->label('Nama Ruangan')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('gedung')
                    ->label('Lokasi'),

                Tables\Columns\TextColumn::make('kapasitas')
                    ->label('Kapasitas')
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
            'index' => Pages\ListRuangans::route('/'),
            'create' => Pages\CreateRuangan::route('/create'),
            'edit' => Pages\EditRuangan::route('/{record}/edit'),
        ];
    }
}
