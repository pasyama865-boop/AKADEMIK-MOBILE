import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/krs.dart';
import '../services/mahasiswa_krs_service.dart';

/// Halaman Jadwal Kuliah Pribadi Mahasiswa.
/// Menampilkan jadwal berdasarkan KRS yang sudah diambil,
/// dikelompokkan per hari dalam format timeline.
class MahasiswaJadwalPage extends StatefulWidget {
  const MahasiswaJadwalPage({super.key});

  @override
  State<MahasiswaJadwalPage> createState() => _MahasiswaJadwalPageState();
}

class _MahasiswaJadwalPageState extends State<MahasiswaJadwalPage> {
  final MahasiswaKrsService _service = MahasiswaKrsService();

  List<Krs> _krsList = [];
  int _totalSks = 0;
  bool _isLoading = true;
  String? _errorMessage;

  final dayOrder = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getMyKrs();
      setState(() {
        _krsList = data['krs'] as List<Krs>;
        _totalSks = data['totalSks'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Jadwal Kuliah Saya',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
          ? _buildError()
          : _krsList.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSemesterHeader(),
                  const SizedBox(height: 16),
                  ..._buildScheduleByDay(),
                ],
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 64),
          SizedBox(height: 16),
          Text(
            'Belum Ada Jadwal',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Silakan ambil mata kuliah di menu KRS\nuntuk melihat jadwal kuliahmu',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterHeader() {
    // Ambil nama semester dari KRS pertama
    final semester = _krsList.isNotEmpty ? _krsList.first.namaSemester : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  semester,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_krsList.length} Mata Kuliah • $_totalSks SKS',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleByDay() {
    // Group by hari
    final Map<String, List<Krs>> grouped = {};
    for (final krs in _krsList) {
      grouped.putIfAbsent(krs.hari, () => []).add(krs);
    }

    // Sort within each day by jam_mulai
    for (final list in grouped.values) {
      list.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
    }

    // Sort days
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        final ia = dayOrder.indexOf(a);
        final ib = dayOrder.indexOf(b);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });

    final widgets = <Widget>[];

    for (final day in sortedDays) {
      final courses = grouped[day]!;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getColorForDay(day),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    day.toUpperCase(),
                    style: TextStyle(
                      color: _getColorForDay(day),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: _getColorForDay(day).withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Timeline entries
              ...courses.map((krs) => _buildTimelineEntry(krs, day)),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildTimelineEntry(Krs krs, String day) {
    final jamStart = krs.jamMulai.length >= 5
        ? krs.jamMulai.substring(0, 5)
        : krs.jamMulai;
    final jamEnd = krs.jamSelesai.length >= 5
        ? krs.jamSelesai.substring(0, 5)
        : krs.jamSelesai;
    final dayColor = _getColorForDay(day);

    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline line
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayColor,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: dayColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dayColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: dayColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$jamStart - $jamEnd',
                        style: TextStyle(
                          color: dayColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mata Kuliah
                    Text(
                      krs.namaMatkul,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Details
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            krs.namaDosen,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.room,
                          color: AppColors.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          krs.namaRuangan,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${krs.sks} SKS',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForDay(String hari) {
    switch (hari.toLowerCase()) {
      case 'senin':
        return Colors.blue;
      case 'selasa':
        return Colors.green;
      case 'rabu':
        return Colors.orange;
      case 'kamis':
        return Colors.purple;
      case 'jumat':
        return Colors.teal;
      case 'sabtu':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
