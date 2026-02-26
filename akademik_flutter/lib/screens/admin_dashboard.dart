import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dosen_page.dart';
import 'krs_page.dart';
import 'mahasiswa_page.dart';
import 'matakuliah_page.dart';
import 'ruangan_page.dart';
import 'semester_page.dart';
import 'user_page.dart';
import 'jadwal_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _adminName = "Admin";
  String _totalMahasiswa = "...";
  String _totalDosen = "...";
  String _totalMataKuliah = "...";
  String _totalJadwal = "...";
  String _totalRuangan = "...";
  String _totalSemester = "...";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _adminName = prefs.getString('name') ?? "Admin";
      });
    }
    try {
      final auth = AuthService();
      final stats = await auth.getAdminStats();
      if (mounted) {
        setState(() {
          _totalMahasiswa = stats['total_mahasiswa'].toString();
          _totalDosen = stats['total_dosen'].toString();
          _totalJadwal = stats['total_jadwal'].toString();
          _totalMataKuliah = stats['total_matakuliah'].toString();
          _totalRuangan = stats['total_ruangan'].toString();
          _totalSemester = stats['total_semester'].toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      drawer: _buildSidebar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeWidget(),
            const SizedBox(height: 20),
            _buildStatCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Akademik",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _adminName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _navItem(Icons.dashboard, "Dashboard", isActive: true),
          _navItem(
            Icons.people_outline,
            "Dosen",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DosenPage()),
              );
            },
          ),
          _navItem(
            Icons.calendar_today,
            "Jadwal Kuliah",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JadwalPage()),
              );
            },
          ),
          _navItem(
            Icons.assignment_ind,
            "KRS Mahasiswa",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KrsPage()),
              );
            },
          ),
          _navItem(
            Icons.school,
            "Mahasiswa",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MahasiswaPage()),
              );
            },
          ),
          _navItem(
            Icons.book,
            "Mata Kuliah",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MataKuliahPage()),
              );
            },
          ),
          _navItem(
            Icons.room,
            "Ruangan",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RuanganPage()),
              );
            },
          ),
          _navItem(
            Icons.event,
            "Semester",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SemesterPage()),
              );
            },
          ),
          _navItem(
            Icons.admin_panel_settings,
            "Admin",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserPage()),
              );
            },
          ),
          const Divider(color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              "Sign out",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () async {
              final authService = AuthService();
              await authService.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      tileColor: isActive
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      onTap: onTap,
    );
  }

  Widget _buildWelcomeWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: Text(
              _adminName[0].toUpperCase(),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                _adminName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard("Mahasiswa", _totalMahasiswa, Icons.school, Colors.blue),
        _statCard("Dosen", _totalDosen, Icons.people_outline, Colors.orange),
        _statCard("Mata Kuliah", _totalMataKuliah, Icons.book, Colors.green),
        _statCard(
          "Jadwal Kuliah",
          _totalJadwal,
          Icons.calendar_today,
          Colors.purple,
        ),
        _statCard("Ruangan", _totalRuangan, Icons.room, Colors.red),
        _statCard("Semester", _totalSemester, Icons.event, Colors.teal),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
