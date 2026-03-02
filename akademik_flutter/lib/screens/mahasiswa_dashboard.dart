import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/app_colors.dart';
import '../services/mahasiswa_krs_service.dart';
import '../services/auth_service.dart';
import '../models/krs.dart';
import 'mahasiswa_krs_page.dart';
import 'mahasiswa_jadwal_page.dart';
import 'login.dart';
import 'profile.dart';
import 'nilai.dart';
import '../widgets/shimmer_loader.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nama = 'Mahasiswa';
  String _nim = '-';
  final String _prodi = 'Program Studi';
  List<Krs> _krsList = [];
  double _ipk = 0.0;
  bool _isLoading = true;
  bool _isOffline = false;
  String _selectedSemester = '2023/2024 Ganjil';
  int _totalSksLulus = 0;

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
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('name') ?? 'Mahasiswa';

      final service = MahasiswaKrsService();
      final krsData = await service.getMyKrs();
      final krsList = krsData['krs'] as List<Krs>;

      int totalSksLulus = 0;
      double totalBobot = 0.0;
      for (var k in krsList) {
        final nilai = k.nilaiAkhir;
        if (nilai != null && nilai.isNotEmpty && nilai != 'null') {
          int sks = k.sks;
          double bobot = nilai == 'A'
              ? 4.0
              : nilai == 'B'
              ? 3.0
              : nilai == 'C'
              ? 2.0
              : nilai == 'D'
              ? 1.0
              : 0.0;
          totalSksLulus += sks;
          totalBobot += (bobot * sks);
        }
      }

      if (mounted) {
        setState(() {
          _nama = nama;
          _nim = prefs.getString('nim') ?? '12345678';
          _krsList = krsList;
          _totalSksLulus = totalSksLulus;
          _ipk = totalSksLulus > 0 ? (totalBobot / totalSksLulus) : 0.0;
          if (_krsList.isNotEmpty)
            _selectedSemester = _krsList.first.namaSemester;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOffline = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda sedang offline — menampilkan data terakhir'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
                  'Anda sedang offline — menampilkan data terakhir',
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
                onRefresh: _loadDashboardData,
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
        _buildSemesterControl(),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Jadwal Terdekat',
          Icons.calendar_today,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MahasiswaJadwalPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildUpcomingSchedule(),
        const SizedBox(height: 24),
        _buildSectionHeader('Aksi Cepat', Icons.flash_on),
        const SizedBox(height: 12),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildSectionHeader('Progres Akademik', Icons.trending_up),
        const SizedBox(height: 12),
        _buildAcademicProgress(),
        const SizedBox(height: 24),
        _buildSectionHeader('Pengumuman', Icons.campaign),
        const SizedBox(height: 12),
        _buildAnnouncements(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAppBar() {
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary .withValues(alpha: 0.2),
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
    final statusColor = _ipk < 2.0 && _ipk > 0
        ? AppColors.error
        : AppColors.success;
    final statusText = _ipk < 2.0 && _ipk > 0 ? 'Peringatan' : 'Aktif';
    final statusIcon = _ipk < 2.0 && _ipk > 0
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black .withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(color: _borderColor),
        gradient: _isDarkMode
            ? null
            : LinearGradient(
                colors: [AppColors.primary .withValues(alpha: 0.05), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
              fontSize: 20,
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
                  'NIM: $_nim',
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
                  _prodi,
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
                'Semester Aktif: ',
                style: TextStyle(color: _textSecondaryColor, fontSize: 12),
              ),
              Text(
                _selectedSemester,
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
                  color: statusColor .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
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
                title: 'IPK',
                value: _ipk.toStringAsFixed(2),
                valueColor: AppColors.primary,
                icon: Icons.auto_graph,
                warning: _ipk < 2.0 && _ipk > 0,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NilaiScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'SKS Lulus',
                value: '$_totalSksLulus',
                subtitle: '/ 144',
                valueColor: AppColors.success,
                icon: Icons.checklist,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Semester Aktif',
                value: 'Smt 4',
                subtitle: 'Ganjil',
                valueColor: AppColors.info,
                icon: Icons.school,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Status',
                value: _ipk < 2.0 && _ipk > 0 ? 'Warning' : 'Aktif',
                valueColor: _ipk < 2.0 && _ipk > 0 ? AppColors.error : AppColors.success,
                icon: Icons.verified_user,
                warning: _ipk < 2.0 && _ipk > 0,
                onTap: () {},
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: warning ? AppColors.error .withValues(alpha: 0.5) : _borderColor,
          ),
          boxShadow: _isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black .withValues(alpha: 0.02),
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
                  color: warning ? AppColors.error : _textSecondaryColor,
                  size: 20,
                ),
                if (warning)
                  Icon(Icons.warning, color: AppColors.error, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: warning ? AppColors.error : _textPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
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

  Widget _buildSemesterControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSemester,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: _textSecondaryColor),
          dropdownColor: _surfaceColor,
          style: TextStyle(
            color: _textPrimaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSemester = newValue;
                _loadDashboardData();
              });
            }
          },
          items: [_selectedSemester].map<DropdownMenuItem<String>>((
            String value,
          ) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text('Semester: $value'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    final hariIni = _namaHari[DateTime.now().weekday] ?? '';
    final jadwalList =
        _krsList
            .where((k) => k.hari.toLowerCase() == hariIni.toLowerCase())
            .toList()
          ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

    final displayList = jadwalList.take(3).toList();

    if (displayList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: _textSecondaryColor .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada kelas hari ini',
              style: TextStyle(
                color: _textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MahasiswaJadwalPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Lihat Jadwal Lengkap'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: displayList.map((krs) {
        final List<Color> accColors = [
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.pink,
        ];
        final accColor = accColors[krs.namaMatkul.length % accColors.length];

        return Container(
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
                      color: Colors.black .withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: accColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      krs.namaMatkul,
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
                          Icons.schedule,
                          size: 12,
                          color: _textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${krs.jamMulai} - ${krs.jamSelesai}',
                          style: TextStyle(
                            color: _textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.room, size: 12, color: _textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          krs.namaRuangan,
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
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: _textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.edit_document,
        'label': 'Isi KRS',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MahasiswaKrsPage()),
        ),
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Jadwal',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MahasiswaJadwalPage()),
        ),
      },
      {
        'icon': Icons.analytics,
        'label': 'Nilai',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NilaiScreen()),
        ),
      },
      {'icon': Icons.history_edu, 'label': 'Transkrip', 'onTap': () => {}},
      {'icon': Icons.how_to_reg, 'label': 'Presensi', 'onTap': () => {}},
      {'icon': Icons.payments, 'label': 'Pembayaran', 'onTap': () => {}},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actions.map((action) {
            final onTap = action['onTap'] as VoidCallback;
            return SizedBox(
              width: width,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: AppColors.primary .withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: _borderColor),
                          boxShadow: _isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
          }).toList(),
        );
      },
    );
  }

  Widget _buildAcademicProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 8.0,
                animation: true,
                percent: (_totalSksLulus / 144).clamp(0.0, 1.0),
                center: Text(
                  "${(_totalSksLulus / 144 * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: _textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppColors.primary,
                backgroundColor: _borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Kelulusan',
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anda telah menyelesaikan $_totalSksLulus SKS dari total 144 SKS yang diwajibkan.',
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
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: _borderColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Smt ${value.toInt() + 1}',
                            style: TextStyle(
                              color: _textSecondaryColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3.2),
                      FlSpot(1, 3.5),
                      FlSpot(2, 3.4),
                      FlSpot(3, 3.7),
                      FlSpot(4, 3.8),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary .withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 4,
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
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '2 Jam yang lalu',
                style: TextStyle(color: _textSecondaryColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pendaftaran KRS Semester Ganjil dibuka',
            style: TextStyle(
              color: _textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Batas akhir pengisian KRS adalah tanggal 15 September 2025. Harap segera mengisi KRS Anda.',
            style: TextStyle(color: _textSecondaryColor, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
