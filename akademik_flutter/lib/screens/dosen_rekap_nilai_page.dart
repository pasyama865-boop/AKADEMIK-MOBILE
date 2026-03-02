import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dosen_dashboard_service.dart';
import '../widgets/shimmer_loader.dart';

class DosenRekapNilaiPage extends StatefulWidget {
  const DosenRekapNilaiPage({super.key});

  @override
  State<DosenRekapNilaiPage> createState() => _DosenRekapNilaiPageState();
}

class _DosenRekapNilaiPageState extends State<DosenRekapNilaiPage> {
  final DosenDashboardService _service = DosenDashboardService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _distribusiNilai = {};
  List<dynamic> _kelasRekap = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _service.getMyStats();
      if (mounted) {
        setState(() {
          _distribusiNilai = stats['distribusi_nilai'] ?? {};
          _kelasRekap = stats['kelas_rekap'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    Color bgColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    Color borderColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    Color textPrimaryColor = isDarkMode
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    Color textSecondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Rekap Nilai",
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: textPrimaryColor),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? Center(
              child: Text(
                "Error: $_error",
                style: const TextStyle(color: AppColors.error),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPieChartSection(
                    surfaceColor,
                    borderColor,
                    textPrimaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rekap Per Kelas",
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_kelasRekap.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Belum ada data kelas",
                          style: TextStyle(color: textSecondaryColor),
                        ),
                      ),
                    ),
                  ..._kelasRekap.map((kelas) {
                    final dist = kelas['distribusi'] ?? {};
                    final a = dist['A'] ?? 0;
                    final b = dist['B'] ?? 0;
                    final c = dist['C'] ?? 0;
                    final d = dist['D'] ?? 0;
                    final e = dist['E'] ?? 0;

                    return _buildKelasRekapCard(
                      surfaceColor,
                      borderColor,
                      textPrimaryColor,
                      textSecondaryColor,
                      kelas['nama_matkul'] ?? 'Unknown',
                      "${kelas['total_mahasiswa']} Mhs",
                      "$a A, $b B, $c C, $d D, $e E",
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildPieChartSection(
    Color surfaceColor,
    Color borderColor,
    Color textPrimaryColor,
  ) {
    int total = _distribusiNilai.values.fold(
      0,
      (sum, val) => sum + (val as int),
    );

    List<PieChartSectionData> sections = [];
    if (total == 0) {
      sections.add(
        PieChartSectionData(
          value: 100,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          title: '0 Data',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      final a = (_distribusiNilai['A'] ?? 0) as int;
      final b = (_distribusiNilai['B'] ?? 0) as int;
      final c = (_distribusiNilai['C'] ?? 0) as int;
      final d = (_distribusiNilai['D'] ?? 0) as int;
      final e = (_distribusiNilai['E'] ?? 0) as int;

      if (a > 0)
        sections.add(_makePieSection(a, total, AppColors.success, 'A'));
      if (b > 0)
        sections.add(_makePieSection(b, total, AppColors.primary, 'B'));
      if (c > 0)
        sections.add(_makePieSection(c, total, AppColors.warning, 'C'));
      if (d > 0) sections.add(_makePieSection(d, total, Colors.orange, 'D'));
      if (e > 0) sections.add(_makePieSection(e, total, AppColors.error, 'E'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Distribusi Nilai Keseluruhan",
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Total $total",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _makePieSection(
    int value,
    int total,
    Color color,
    String label,
  ) {
    int percent = (value / total * 100).round();
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: '$label ($percent%)',
      radius: 40,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildKelasRekapCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    String matkul,
    String count,
    String details,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  matkul,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(details, style: TextStyle(color: textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ShimmerLoader(width: double.infinity, height: 250, borderRadius: 16),
        const SizedBox(height: 16),
        ShimmerLoader(width: 150, height: 20, borderRadius: 8),
        const SizedBox(height: 12),
        ShimmerLoader(width: double.infinity, height: 80, borderRadius: 12),
        const SizedBox(height: 12),
        ShimmerLoader(width: double.infinity, height: 80, borderRadius: 12),
      ],
    );
  }
}
