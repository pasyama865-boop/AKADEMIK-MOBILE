import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../services/dosen_dashboard_service.dart';
import 'login.dart';
import 'profile.dart';
import 'dosen_input_nilai.dart';
import 'dosen_approval_krs.dart';
import 'dosen_jadwal_page.dart';
import 'dosen_presensi_page.dart';
import 'dosen_rekap_nilai_page.dart';
import 'dosen_laporan_page.dart';
import '../widgets/shimmer_loader.dart';

class DosenDashboard extends StatefulWidget {
  const DosenDashboard({super.key});

  @override
  State<DosenDashboard> createState() => _DosenDashboardState();
}

class _DosenDashboardState extends State<DosenDashboard> {
  String _nama = 'Dosen';
  String _nidn = '02134567';
  final String _jabatan = 'Dosen Tetap';
  final String _semesterAktif = '2025/2026 Ganjil';
  bool _isLoading = true;
  bool _isOffline = false;

  int _totalKelas = 0;
  int _totalMahasiswa = 0;
  int _krsPending = 0;
  int _nilaiDraft = 0;
  int _publikasiPersen = 0;
  Map<String, dynamic> _distribusiNilai = {};
  List<dynamic> _jadwalList = [];

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Dosen';

      final service = DosenDashboardService();
      final results = await Future.wait([
        service.getMyStats(),
        service.getMyJadwal(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final jadwal = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _nama = nama;
          _nidn = prefs.getString('nidn') ?? '02134567';
          _totalKelas = stats['total_kelas'] ?? 0;
          _totalMahasiswa = stats['total_mahasiswa'] ?? 0;
          _krsPending = stats['krs_pending'] ?? 0;
          _nilaiDraft = stats['nilai_draft'] ?? 0;
          _publikasiPersen = stats['publikasi_persen'] ?? 0;
          _distribusiNilai = stats['distribusi_nilai'] ?? {};
          _jadwalList = jadwal;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;
        setState(() {
          _nama = prefs.getString('name') ?? 'Dosen';
          _isLoading = false;
          _isOffline = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda sedang offline — menampilkan data terakhir'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Keluar", style: TextStyle(color: _textPrimaryColor)),
        content: Text(
          "Yakin ingin keluar?",
          style: TextStyle(color: _textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: _textSecondaryColor)),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  bool get _isDarkMode {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color get _surfaceColor =>
      _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get _bgColor =>
      _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _textPrimaryColor =>
      _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _textSecondaryColor =>
      _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _borderColor =>
      _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  List<dynamic> get _jadwalHariIni {
    final hariIni = _namaHari[DateTime.now().weekday] ?? '';
    return _jadwalList
        .where(
          (j) =>
              (j['hari'] ?? '').toString().toLowerCase() ==
              hariIni.toLowerCase(),
        )
        .toList()
      ..sort((a, b) => (a['jam_mulai'] ?? '').compareTo(b['jam_mulai'] ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                color: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  'Offline — menampilkan data terakhir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _isLoading ? _buildLoading() : _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ShimmerLoader(width: double.infinity, height: 160, borderRadius: 16),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ShimmerLoader(
                width: double.infinity,
                height: 100,
                borderRadius: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShimmerLoader(
                width: double.infinity,
                height: 100,
                borderRadius: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ShimmerLoader(width: double.infinity, height: 80, borderRadius: 16),
        const SizedBox(height: 16),
        ShimmerLoader(width: double.infinity, height: 200, borderRadius: 16),
      ],
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildGreeting(),
        const SizedBox(height: 16),
        _buildAcademicSummary(),
        const SizedBox(height: 16),
        _buildAlertSection(),
        const SizedBox(height: 24),
        _buildSectionHeader('Jadwal Mengajar Hari Ini', Icons.today),
        const SizedBox(height: 12),
        _buildJadwalHariIniWidget(),
        const SizedBox(height: 24),
        _buildSectionHeader('Aksi Cepat', Icons.flash_on),
        const SizedBox(height: 12),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildSectionHeader('Statistik Akademik', Icons.bar_chart),
        const SizedBox(height: 12),
        _buildStatistikAkademik(),
        const SizedBox(height: 24),
        _buildSectionHeader('Info Akademik', Icons.campaign),
        const SizedBox(height: 12),
        _buildAnnouncements(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAppBar() {
    final hasNotification = _krsPending > 0 || _nilaiDraft > 0;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: _textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: _textPrimaryColor,
                    ),
                    onPressed: () {},
                  ),
                  if (hasNotification)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()},',
            style: TextStyle(color: _textSecondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _nama,
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NIDN: $_nidn',
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _jabatan,
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Semester: ',
                style: TextStyle(color: _textSecondaryColor, fontSize: 12),
              ),
              Text(
                _semesterAktif,
                style: TextStyle(
                  color: _textPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Aktif Mengajar',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Kelas',
                value: '$_totalKelas',
                subtitle: 'Kelas',
                valueColor: AppColors.primary,
                icon: Icons.class_,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DosenJadwalPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Mahasiswa',
                value: '$_totalMahasiswa',
                subtitle: 'Mahasiswa',
                valueColor: AppColors.info,
                icon: Icons.people,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DosenJadwalPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'KRS Pending',
                value: '$_krsPending',
                valueColor: _krsPending > 0
                    ? AppColors.warning
                    : AppColors.success,
                icon: Icons.assignment_late,
                warning: _krsPending > 0,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DosenApprovalKrs()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Nilai Draft',
                value: '$_nilaiDraft',
                subtitle: 'Kelas',
                valueColor: _nilaiDraft > 0
                    ? AppColors.error
                    : AppColors.success,
                icon: Icons.grading,
                danger: _nilaiDraft > 0,
                onTap: () {
                  if (_nilaiDraft > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DosenJadwalPage(actionType: 'input_nilai'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    String? subtitle,
    bool warning = false,
    bool danger = false,
    VoidCallback? onTap,
  }) {
    final hasIssue = warning || danger;
    final issueColor = warning
        ? AppColors.warning
        : (danger ? AppColors.error : _textSecondaryColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasIssue ? issueColor.withValues(alpha: 0.5) : _borderColor,
          ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: hasIssue ? issueColor : _textSecondaryColor,
                  size: 20,
                ),
                if (hasIssue)
                  Icon(Icons.error_outline, color: issueColor, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: hasIssue ? issueColor : _textPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: _textSecondaryColor, fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection() {
    List<Widget> alerts = [];

    if (_krsPending > 0) {
      alerts.add(
        _buildAlertCard(
          "Terdapat $_krsPending KRS menunggu persetujuan",
          AppColors.warning,
          Icons.warning_amber_rounded,
          "Review Sekarang",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DosenApprovalKrs()),
          ),
        ),
      );
    }

    if (_nilaiDraft > 0) {
      alerts.add(
        _buildAlertCard(
          "$_nilaiDraft kelas belum dipublish nilainya",
          AppColors.error,
          Icons.report_problem_rounded,
          "Selesaikan",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DosenJadwalPage(actionType: 'input_nilai'),
              ),
            );
          },
        ),
      );
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(children: alerts);
  }

  Widget _buildAlertCard(
    String message,
    Color color,
    IconData icon,
    String btnText,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              btnText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: _textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalHariIniWidget() {
    final jadwal = _jadwalHariIni;

    if (jadwal.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: _textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada jadwal mengajar hari ini',
              style: TextStyle(
                color: _textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DosenJadwalPage()),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lihat Jadwal Lengkap',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: jadwal.take(3).map((item) {
        final matkul = item['mata_kuliah'];
        final ruangan = item['ruangan'];
        final namaMatkul = matkul?['nama_matkul'] ?? 'Unknown';
        final namaRuangan = ruangan?['nama'] ?? 'Unknown';
        final jamMulai =
            item['jam_mulai']?.toString().substring(0, 5) ?? '00:00';
        final jamSelesai =
            item['jam_selesai']?.toString().substring(0, 5) ?? '00:00';
        final krsCount = item['krs_count'] ?? 0;
        final id = item['id']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$jamMulai - $jamSelesai',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.room,
                              size: 12,
                              color: _textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              namaRuangan,
                              style: TextStyle(
                                color: _textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.people,
                              size: 12,
                              color: _textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$krsCount Mhs',
                              style: TextStyle(
                                color: _textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (id.isNotEmpty) {
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
                      icon: const Icon(Icons.how_to_reg, size: 16),
                      label: const Text(
                        'Presensi',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: _borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (id.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DosenInputNilai(
                                jadwalId: id,
                                namaMatkul: namaMatkul,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.grading, size: 16),
                      label: const Text(
                        'Input Nilai',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: _borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.grading,
        'label': 'Input Nilai',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DosenJadwalPage(actionType: 'input_nilai'),
            ),
          );
        },
      },
      {
        'icon': Icons.rule,
        'label': 'Approval KRS',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DosenApprovalKrs()),
        ),
      },
      {
        'icon': Icons.co_present,
        'label': 'Presensi',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DosenJadwalPage(actionType: 'presensi'),
            ),
          );
        },
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Jadwal',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DosenJadwalPage()),
          );
        },
      },
      {
        'icon': Icons.assessment,
        'label': 'Rekap Nilai',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DosenRekapNilaiPage()),
          );
        },
      },
      {
        'icon': Icons.pie_chart,
        'label': 'Laporan',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DosenLaporanPage()),
          );
        },
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: actions.map((action) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = (MediaQuery.of(context).size.width - 64) / 3;
            return SizedBox(
              width: width,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: action['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: _borderColor),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatistikAkademik() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 36.0,
                lineWidth: 8.0,
                animation: true,
                percent: _publikasiPersen / 100,
                center: Text(
                  "$_publikasiPersen%",
                  style: TextStyle(
                    color: _textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppColors.success,
                backgroundColor: _borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publikasi Nilai',
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_publikasiPersen% dari total kelas semester ini telah mempublikasikan nilai final.',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Statistik Rata-Rata Nilai (Simulasi)',
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('A', style: style);
                            break;
                          case 1:
                            text = const Text('B', style: style);
                            break;
                          case 2:
                            text = const Text('C', style: style);
                            break;
                          case 3:
                            text = const Text('D', style: style);
                            break;
                          case 4:
                            text = const Text('E', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: _borderColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: (_distribusiNilai['A'] ?? 0).toDouble(),
                        color: AppColors.success,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: (_distribusiNilai['B'] ?? 0).toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: (_distribusiNilai['C'] ?? 0).toDouble(),
                        color: AppColors.warning,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: (_distribusiNilai['D'] ?? 0).toDouble(),
                        color: Colors.orange,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(
                        toY: (_distribusiNilai['E'] ?? 0).toDouble(),
                        color: AppColors.error,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kemarin, 14:00',
                style: TextStyle(color: _textSecondaryColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Batas Waktu Input Nilai Semester Ganjil',
            style: TextStyle(
              color: _textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bapak/Ibu dosen yang terhormat, mengingatkan kembali bahwa batas akhir pengisian dan publikasi nilai adalah 30 Januari 2026. Mohon untuk segera menyelesaikannya.',
            style: TextStyle(color: _textSecondaryColor, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
