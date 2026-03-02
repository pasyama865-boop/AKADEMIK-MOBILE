import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/dosen_dashboard_service.dart';
import 'dosen_input_nilai.dart';
import 'dosen_presensi_page.dart';
import '../widgets/shimmer_loader.dart';

class DosenJadwalPage extends StatefulWidget {
  final String?
  actionType; // 'input_nilai', 'presensi', atau null (hanya lihat)
  const DosenJadwalPage({super.key, this.actionType});

  @override
  State<DosenJadwalPage> createState() => _DosenJadwalPageState();
}

class _DosenJadwalPageState extends State<DosenJadwalPage> {
  final DosenDashboardService _service = DosenDashboardService();
  List<dynamic> _jadwalList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.getMyJadwal();
      setState(() {
        _jadwalList = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          // Fallback dummy for prototype
          if (e.toString().contains('Connection')) {
            _jadwalList = [
              {
                'id': '1',
                'mata_kuliah': {'nama_matkul': 'Pemrograman Mobile'},
                'ruangan': {'nama': 'Lab Komputer 1'},
                'hari': 'Senin',
                'jam_mulai': '08:00',
                'jam_selesai': '10:30',
                'krs_count': 35,
              },
              {
                'id': '2',
                'mata_kuliah': {'nama_matkul': 'Sistem Operasi'},
                'ruangan': {'nama': 'Ruang 102'},
                'hari': 'Kamis',
                'jam_mulai': '13:00',
                'jam_selesai': '15:30',
                'krs_count': 40,
              },
            ];
            _error = null;
          }
        });
      }
    }
  }

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor =>
      _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get _borderColor =>
      _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get _textPrimaryColor =>
      _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _textSecondaryColor =>
      _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    String title = "Jadwal Mengajar";
    if (widget.actionType == 'input_nilai')
      title = "Pilih Jadwal untuk Input Nilai";
    if (widget.actionType == 'presensi') title = "Pilih Jadwal untuk Presensi";

    return Scaffold(
      backgroundColor: _isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: _textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _surfaceColor,
        iconTheme: IconThemeData(color: _textPrimaryColor),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderColor, height: 1.0),
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
          : _jadwalList.isEmpty
          ? Center(
              child: Text(
                "Tidak ada jadwal mengajar.",
                style: TextStyle(color: _textSecondaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchJadwal,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _jadwalList.length,
                itemBuilder: (context, index) {
                  final item = _jadwalList[index];
                  final matkul = item['mata_kuliah'];
                  final ruangan = item['ruangan'];
                  final namaMatkul = matkul?['nama_matkul'] ?? 'Unknown';
                  final namaRuangan = ruangan?['nama'] ?? 'Unknown';
                  final hari = item['hari'] ?? '-';
                  final jamMulai =
                      item['jam_mulai']?.toString().substring(0, 5) ?? '00:00';
                  final jamSelesai =
                      item['jam_selesai']?.toString().substring(0, 5) ??
                      '00:00';
                  final krsCount = item['krs_count'] ?? 0;
                  final id = item['id']?.toString() ?? '';

                  return GestureDetector(
                    onTap: () {
                      if (widget.actionType == 'input_nilai') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DosenInputNilai(
                              jadwalId: id,
                              namaMatkul: namaMatkul,
                            ),
                          ),
                        );
                      } else if (widget.actionType == 'presensi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DosenPresensiPage(
                              jadwalId: id,
                              namaMatkul: namaMatkul,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor),
                        boxShadow: _isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      hari,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$jamMulai\n$jamSelesai',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      namaMatkul,
                                      style: TextStyle(
                                        color: _textPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.room,
                                          size: 14,
                                          color: _textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          namaRuangan,
                                          style: TextStyle(
                                            color: _textSecondaryColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 14,
                                          color: _textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$krsCount Mahasiswa',
                                          style: TextStyle(
                                            color: _textSecondaryColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.actionType != null)
                                Icon(
                                  Icons.chevron_right,
                                  color: _textSecondaryColor,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoader(
          width: double.infinity,
          height: 100,
          borderRadius: 16,
        ),
      ),
    );
  }
}
