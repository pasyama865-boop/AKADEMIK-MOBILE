import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../services/dosen_dashboard_service.dart';
import 'login.dart';
import 'profile.dart';

class DosenDashboard extends StatefulWidget {
  const DosenDashboard({super.key});

  @override
  State<DosenDashboard> createState() => _DosenDashboardState();
}

class _DosenDashboardState extends State<DosenDashboard> {
  String _nama = 'Dosen';
  bool _isLoading = true;
  int _totalKelas = 0;
  int _totalMahasiswa = 0;
  int _totalSks = 0;
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
          _totalKelas = stats['total_kelas'] ?? 0;
          _totalMahasiswa = stats['total_mahasiswa'] ?? 0;
          _totalSks = stats['total_sks'] ?? 0;
          _jadwalList = jadwal;
          _isLoading = false;
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _nama = prefs.getString('name') ?? 'Dosen';
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
          "Yakin ingin keluar?",
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

  /// Jadwal hari ini
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

  /// Jadwal dikelompokkan per hari
  Map<String, List<dynamic>> get _jadwalPerHari {
    final result = <String, List<dynamic>>{};
    final urutan = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    for (final hari in urutan) {
      final items =
          _jadwalList
              .where(
                (j) =>
                    (j['hari'] ?? '').toString().toLowerCase() ==
                    hari.toLowerCase(),
              )
              .toList()
            ..sort(
              (a, b) => (a['jam_mulai'] ?? '').compareTo(b['jam_mulai'] ?? ''),
            );
      if (items.isNotEmpty) {
        result[hari] = items;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Dashboard Dosen",
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
        onRefresh: _loadData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),

                    // 2. Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // 3. Jadwal Hari Ini
                    _buildSectionTitle(
                      'Jadwal Mengajar Hari Ini',
                      Icons.today,
                      subtitle: _namaHari[DateTime.now().weekday] ?? '',
                    ),
                    const SizedBox(height: 12),
                    _buildJadwalHariIni(),
                    const SizedBox(height: 24),

                    // 4. Semua Jadwal Mengajar
                    _buildSectionTitle(
                      'Jadwal Mengajar Minggu Ini',
                      Icons.calendar_month,
                      subtitle: '${_jadwalList.length} Kelas',
                    ),
                    const SizedBox(height: 12),
                    _buildSemuaJadwal(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ===== WIDGET BUILDERS =====

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF059669),
            const Color(0xFF34D399).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Selamat mengajar hari ini',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.co_present, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.class_,
            label: 'Kelas',
            value: '$_totalKelas',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            label: 'Mahasiswa',
            value: '$_totalMahasiswa',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            label: 'Total SKS',
            value: '$_totalSks',
            color: Colors.orange,
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

  /// Jadwal hari ini
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
              _totalKelas > 0 ? Icons.free_breakfast : Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _totalKelas > 0
                  ? 'Tidak ada kelas hari ini 🎉'
                  : 'Belum ada jadwal mengajar',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _totalKelas > 0
                  ? 'Nikmati hari bebasmu!'
                  : 'Hubungi admin untuk pengaturan jadwal',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(children: jadwal.map((j) => _buildJadwalCard(j)).toList());
  }

  /// Semua jadwal dikelompokkan per hari
  Widget _buildSemuaJadwal() {
    final grouped = _jadwalPerHari;

    if (grouped.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'Belum ada jadwal',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: grouped.entries.map((entry) {
        final hari = entry.key;
        final items = entry.value;
        final color = _getColorForDay(hari);
        final isToday =
            hari.toLowerCase() ==
            (_namaHari[DateTime.now().weekday] ?? '').toLowerCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(
                        color: color.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: color, size: 10),
                  const SizedBox(width: 8),
                  Text(
                    hari,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HARI INI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${items.length} kelas',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Jadwal cards
            ...items.map((j) => _buildJadwalCard(j)),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  /// Card jadwal individual
  Widget _buildJadwalCard(dynamic jadwal) {
    final matkul = jadwal['mata_kuliah'];
    final ruangan = jadwal['ruangan'];
    final namaMatkul = matkul?['nama_matkul'] ?? 'Mata Kuliah';
    final sks = matkul?['sks'] ?? 0;
    final namaRuangan = ruangan?['nama'] ?? 'Ruangan';
    final hari = jadwal['hari'] ?? '-';
    final jamMulai = (jadwal['jam_mulai'] ?? '').toString();
    final jamSelesai = (jadwal['jam_selesai'] ?? '').toString();
    final kuota = jadwal['kuota'] ?? 0;
    final peserta = jadwal['krs_count'] ?? 0;

    final jamStart = jamMulai.length >= 5 ? jamMulai.substring(0, 5) : jamMulai;
    final jamEnd = jamSelesai.length >= 5
        ? jamSelesai.substring(0, 5)
        : jamSelesai;
    final dayColor = _getColorForDay(hari);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dayColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  jamStart,
                  style: TextStyle(
                    color: dayColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  width: 1,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: dayColor.withValues(alpha: 0.4),
                ),
                Text(
                  jamEnd,
                  style: TextStyle(
                    color: dayColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaMatkul,
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
                      Icons.room,
                      color: AppColors.textSecondary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      namaRuangan,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    // SKS badge
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
                        '$sks SKS',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Peserta bar
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.textSecondary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$peserta / $kuota Mahasiswa',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: kuota > 0 ? peserta / kuota : 0,
                          backgroundColor: AppColors.textSecondary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            peserta >= kuota ? AppColors.error : dayColor,
                          ),
                          minHeight: 4,
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
