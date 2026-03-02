import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/krs.dart';
import '../services/mahasiswa_krs_service.dart';

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  final MahasiswaKrsService _krsService = MahasiswaKrsService();
  late Future<List<Krs>> _krsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _krsFuture = _krsService.getMyKrs().then((data) {
        final List<Krs> allKrs = data['krs'] as List<Krs>;
        // KHS/Nilai screen ONLY shows courses that already have grades
        return allKrs
            .where(
              (k) =>
                  k.nilaiAkhir != null &&
                  k.nilaiAkhir!.isNotEmpty &&
                  k.nilaiAkhir != 'null',
            )
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Nilai & KHS",
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
                "Belum ada nilai yang keluar.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          final krsList = snapshot.data!;
          // Hitung IP & SKS
          int totalSks = 0;
          double totalBobot = 0.0;
          for (var k in krsList) {
            final nilai = k.nilaiAkhir;
            if (nilai != null && nilai.isNotEmpty) {
              int sks = k.sks;
              double bobot = 0;
              if (nilai == 'A')
                bobot = 4.0;
              else if (nilai == 'B')
                bobot = 3.0;
              else if (nilai == 'C')
                bobot = 2.0;
              else if (nilai == 'D')
                bobot = 1.0;
              else if (nilai == 'E')
                bobot = 0.0;

              totalSks += sks;
              totalBobot += (bobot * sks);
            }
          }
          final String ipSemester = totalSks > 0
              ? (totalBobot / totalSks).toStringAsFixed(2)
              : "0.00";

          return Column(
            children: [
              _buildSummaryCard(ipSemester, totalSks),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: krsList.length,
                  itemBuilder: (context, index) =>
                      _buildKrsCard(krsList[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String ip, int totalSks) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                "Indeks Prestasi",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                ip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Column(
            children: [
              const Text(
                "Total SKS Lulus",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "$totalSks",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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
            "${krs.sks} SKS • Semester ${krs.namaSemester}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
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
