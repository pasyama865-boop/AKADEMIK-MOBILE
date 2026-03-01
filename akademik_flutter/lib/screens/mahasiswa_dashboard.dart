import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../services/mahasiswa_krs_service.dart';
import '../models/krs.dart';
import 'mahasiswa_krs_page.dart';
import 'mahasiswa_jadwal_page.dart';
import 'login.dart';
import 'profile.dart';
import 'nilai.dart';
import '../widgets/shimmer_loader.dart';
import '../utils/pdf_export_util.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nama = 'Mahasiswa';
  int _totalSks = 0;
  int _totalMatkul = 0;
  bool _isLoading = true;
  List<Krs> _krsList = [];

  // Hari-hari dalam bahasa Indonesia
  static const _namaHari = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Mahasiswa';

      final service = MahasiswaKrsService();
      final krsData = await service.getMyKrs();
      final krsList = krsData['krs'] as List<Krs>;
      final totalSks = krsData['totalSks'] as int;

      if (mounted) {
        setState(() {
          _nama = nama;
          _totalSks = totalSks;
          _totalMatkul = krsList.length;
          _krsList = krsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        // Tampilkan snackbar jika ada error koneksi / offline
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () {
                setState(() => _isLoading = true);
                _loadDashboardData();
              },
            ),
          ),
        );

        setState(() {
          _nama = prefs.getString('name') ?? 'Mahasiswa';
          _isLoading = false;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Keluar",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "Yakin ingin Keluar?",
          style: TextStyle(color: AppColors.textSecondary),
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
              "Ya, Keluar",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final authService = AuthService();
    await authService.logout();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil Keluar!"),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Ambil jadwal hari ini dari KRS list
  List<Krs> get _jadwalHariIni {
    final hariIni = _namaHari[DateTime.now().weekday] ?? '';
    return _krsList
        .where((k) => k.hari.toLowerCase() == hariIni.toLowerCase())
        .toList()
      ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
  }

  /// Cek apakah KRS sudah diisi
  bool get _krsStatus => _totalMatkul > 0;

  /// Ambil KRS yang sudah memiliki nilai
  List<Krs> get _krsWithNilai {
    return _krsList
        .where(
          (k) =>
              k.nilaiAkhir != null &&
              k.nilaiAkhir!.isNotEmpty &&
              k.nilaiAkhir != 'null',
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Dashboard Mahasiswa",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primary),
            onPressed: () async {
              try {
                // Tampilkan snackbar progress
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyiapkan file PDF...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await PdfExportUtil.generateAndPrintKhsPdf(
                  _nama,
                  _krsList,
                  _totalSks,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal membuat PDF'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            tooltip: 'Cetak/Uduh KHS',
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => _logout(context),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Header
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),

                    // 2. Status KRS - Alur Kerja Utama
                    _buildKrsStatusCard(),
                    const SizedBox(height: 20),

                    // 3. Quick Stats Row
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // 4. Jadwal Hari Ini
                    _buildSectionTitle(
                      'Jadwal Hari Ini',
                      Icons.today,
                      subtitle: _namaHari[DateTime.now().weekday] ?? '',
                    ),
                    const SizedBox(height: 12),
                    _buildJadwalHariIni(),
                    const SizedBox(height: 24),

                    // 5. Riwayat Nilai Semester Lalu
                    if (_krsWithNilai.isNotEmpty) ...[
                      _buildSectionTitle(
                        'Riwayat Nilai',
                        Icons.assessment,
                        subtitle: '${_krsWithNilai.length} MK',
                      ),
                      const SizedBox(height: 12),
                      _buildRiwayatNilai(),
                      const SizedBox(height: 24),
                    ],

                    // 6. Menu Navigasi
                    _buildSectionTitle('Menu Akademik', Icons.apps),
                    const SizedBox(height: 12),
                    _buildMenuList(),
                    const SizedBox(height: 24),

                    // 7. Panduan Alur Kerja KRS
                    _buildSectionTitle('Panduan Alur KRS', Icons.info_outline),
                    const SizedBox(height: 12),
                    _buildAlurKerja(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // WIDGET BUILDERS

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(
            width: double.infinity,
            height: 120,
            borderRadius: 16,
          ),
          const SizedBox(height: 20),
          const ShimmerLoader(
            width: double.infinity,
            height: 80,
            borderRadius: 14,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: const ShimmerLoader(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: const ShimmerLoader(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: const ShimmerLoader(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerLoader(width: 150, height: 20, borderRadius: 4),
          const SizedBox(height: 12),
          const ShimmerLoader(
            width: double.infinity,
            height: 150,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_nama! 👋',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Selamat datang di Sistem Akademik',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$_totalSks',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'SKS',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card status KRS - Call‑to‑action utama
  Widget _buildKrsStatusCard() {
    final bool sudahIsi = _krsStatus;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MahasiswaKrsPage()),
        ).then((_) => _loadDashboardData());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sudahIsi
                ? AppColors.success.withValues(alpha: 0.4)
                : Colors.blue.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sudahIsi
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                sudahIsi ? Icons.check_circle : Icons.edit_note,
                color: sudahIsi ? AppColors.success : Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sudahIsi ? 'KRS Sudah Diisi ✓' : 'KRS Belum Diisi',
                    style: TextStyle(
                      color: sudahIsi ? AppColors.success : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sudahIsi
                        ? '$_totalMatkul Mata Kuliah • $_totalSks / 24 SKS'
                        : 'Ketuk untuk mulai memilih mata kuliah',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: sudahIsi ? AppColors.success : Colors.blue,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book,
            label: 'Mata Kuliah',
            value: '$_totalMatkul',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            label: 'SKS Terisi',
            value: '$_totalSks',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.data_usage,
            label: 'Sisa Kuota',
            value: '${24 - _totalSks}',
            color: (24 - _totalSks) > 0 ? Colors.orange : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Section Title dengan Icon
  Widget _buildSectionTitle(String title, IconData icon, {String? subtitle}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Jadwal Hari Ini - Preview jadwal kuliah hari ini
  Widget _buildJadwalHariIni() {
    final jadwal = _jadwalHariIni;

    if (jadwal.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(
              _totalMatkul > 0 ? Icons.free_breakfast : Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _totalMatkul > 0
                  ? 'Tidak ada kuliah hari ini 🎉'
                  : 'Belum ada jadwal',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _totalMatkul > 0
                  ? 'Nikmati hari bebasmu!'
                  : 'Isi KRS terlebih dahulu untuk melihat jadwal',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: jadwal.map((krs) {
        final jamStart = krs.jamMulai.length >= 5
            ? krs.jamMulai.substring(0, 5)
            : krs.jamMulai;
        final jamEnd = krs.jamSelesai.length >= 5
            ? krs.jamSelesai.substring(0, 5)
            : krs.jamSelesai;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getColorForDay(krs.hari).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Time column
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getColorForDay(krs.hari).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      jamStart,
                      style: TextStyle(
                        color: _getColorForDay(krs.hari),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: _getColorForDay(krs.hari).withValues(alpha: 0.4),
                    ),
                    Text(
                      jamEnd,
                      style: TextStyle(
                        color: _getColorForDay(krs.hari).withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      krs.namaMatkul,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            krs.namaDosen,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.room,
                          color: AppColors.textSecondary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          krs.namaRuangan,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${krs.sks} SKS',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Menu Navigasi - Horizontal list tiles
  /// Riwayat Nilai - Menampilkan mata kuliah yang sudah memiliki nilai
  Widget _buildRiwayatNilai() {
    final nilaiList = _krsWithNilai;
    // Tampilkan maksimal 5 item, sisanya bisa dilihat di halaman Nilai
    final displayList = nilaiList.length > 5
        ? nilaiList.sublist(0, 5)
        : nilaiList;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // List nilai
          ...displayList.map((krs) {
            final nilai = krs.nilaiAkhir ?? '-';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Grade circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getWarnaNilai(nilai).withValues(alpha: 0.15),
                      border: Border.all(
                        color: _getWarnaNilai(nilai).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nilai,
                        style: TextStyle(
                          color: _getWarnaNilai(nilai),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          krs.namaMatkul,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${krs.sks} SKS • ${krs.namaDosen}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Semester badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      krs.namaSemester,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Divider & "Lihat Semua" button
          if (nilaiList.length > 5) ...[
            const Divider(color: AppColors.divider, height: 8),
            const SizedBox(height: 4),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NilaiScreen()),
                );
              },
              icon: const Icon(Icons.assessment, size: 18),
              label: Text(
                nilaiList.length > 5
                    ? 'Lihat Semua (${nilaiList.length} Mata Kuliah)'
                    : 'Lihat Detail Nilai',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Warna berdasarkan grade
  Color _getWarnaNilai(String? nilai) {
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
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  /// Menu Navigasi - Horizontal list tiles
  Widget _buildMenuList() {
    final menuItems = [
      _MenuData(
        icon: Icons.edit_note,
        label: 'Isi KRS',
        desc: 'Pilih & ambil mata kuliah',
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MahasiswaKrsPage()),
          ).then((_) => _loadDashboardData());
        },
      ),
      _MenuData(
        icon: Icons.calendar_month,
        label: 'Jadwal Kuliah',
        desc: 'Lihat jadwal satu semester',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MahasiswaJadwalPage()),
          );
        },
      ),
      _MenuData(
        icon: Icons.assessment,
        label: 'Nilai / Transkrip',
        desc: 'Lihat nilai mata kuliah',
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NilaiScreen()),
          );
        },
      ),
    ];

    return Column(
      children: menuItems.map((menu) => _buildMenuTile(menu)).toList(),
    );
  }

  Widget _buildMenuTile(_MenuData menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: menu.color.withValues(alpha: 0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: menu.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: menu.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(menu.icon, color: menu.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        menu.desc,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Panduan Alur Kerja KRS - Langkah-langkah visual
  Widget _buildAlurKerja() {
    final steps = [
      _StepData(
        number: '1',
        title: 'Isi KRS',
        desc: 'Pilih jadwal mata kuliah yang ingin diambil',
        icon: Icons.edit_note,
        isComplete: _krsStatus,
      ),
      _StepData(
        number: '2',
        title: 'Cek Jadwal',
        desc: 'Pastikan jadwal tidak bentrok & kuota tersedia',
        icon: Icons.fact_check,
        isComplete: _krsStatus,
      ),
      _StepData(
        number: '3',
        title: 'Submit KRS',
        desc: 'Sistem akan validasi SKS maks 24 & kuota kelas',
        icon: Icons.send,
        isComplete: _krsStatus,
      ),
      _StepData(
        number: '4',
        title: 'Lihat Jadwal',
        desc: 'Jadwal pribadi siap untuk satu semester',
        icon: Icons.calendar_today,
        isComplete: _krsStatus,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator column
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      // Number circle
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isComplete
                              ? AppColors.success
                              : AppColors.primary.withValues(alpha: 0.2),
                          border: Border.all(
                            color: step.isComplete
                                ? AppColors.success
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: step.isComplete
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  step.number,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      // Connecting line
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: step.isComplete
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.2,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: TextStyle(
                                  color: step.isComplete
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.desc,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          step.icon,
                          color: step.isComplete
                              ? AppColors.success.withValues(alpha: 0.5)
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Helper: Warna per hari
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

/// Data class untuk menu item
class _MenuData {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _MenuData({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });
}

/// Data class untuk step panduan
class _StepData {
  final String number;
  final String title;
  final String desc;
  final IconData icon;
  final bool isComplete;

  const _StepData({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.isComplete,
  });
}
