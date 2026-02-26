import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/krs.dart';
import '../services/krs_service.dart';

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  final KrsService _krsService = KrsService();
  late Future<List<Krs>> _krsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _krsFuture = _krsService.getKrsList();
    });
  }

  Future<void> _handleDelete(String id, String namaMatkul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Hapus Mata Kuliah",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "Yakin ingin membatalkan $namaMatkul?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _krsService.deleteKrs(id);
      if (mounted) {
        _showSnackBar("Mata kuliah berhasil dihapus!");
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Gagal: ${e.toString()}", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Daftar Nilai & KRS",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Krs>>(
        future: _krsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Terjadi Kesalahan:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: _refreshData,
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada mata kuliah yang diambil.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          final krsList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: krsList.length,
            itemBuilder: (context, index) => _buildKrsCard(krsList[index]),
          );
        },
      ),
    );
  }

  Widget _buildKrsCard(Krs krs) {
    final String? nilai = krs.nilaiAkhir;
    final bool isNilaiMasuk = nilai != null && nilai.isNotEmpty;

    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getWarnaNilai(nilai),
          child: Text(
            isNilaiMasuk ? nilai : '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          krs.namaMatkul,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "${krs.hari} • ${krs.jamFormatted}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        trailing: !isNilaiMasuk
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: "Batalkan Mata Kuliah",
                onPressed: () => _handleDelete(krs.id, krs.namaMatkul),
              )
            : null,
      ),
    );
  }

  Color _getWarnaNilai(dynamic nilai) {
    switch (nilai) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      case 'E':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
