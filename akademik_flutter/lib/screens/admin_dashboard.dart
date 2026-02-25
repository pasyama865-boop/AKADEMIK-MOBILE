import 'jadwal_page.dart';
import 'package:akademik_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dosen_page.dart';
import 'krs_page.dart';
import 'mahasiswa_page.dart';
import 'matakuliah_page.dart';
import 'ruangan_page.dart';
import 'semester_page.dart';
import 'user_page.dart';

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
        _adminName = prefs.getString('name') ?? "pasha";
      });
    }
    try {
      final auth = AuthService();
      final stats = await auth.getAdminStats();
      debugPrint("Isi kotak dari laravel: $stats");

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      // 1. SIDEBAR FILAMENT
      drawer: _buildFilamentSidebar(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. WELCOME
            _buildWelcomeWidget(),

            const SizedBox(height: 20),

            // 3. STATS
            _buildStatCards(),
          ],
        ),
      ),
    );
  }

  //  KOMPONEN SIDEBAR
  Widget _buildFilamentSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F2937),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF111827)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Laravel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_adminName, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          _navItem(Icons.dashboard, "Dashboard", Colors.amber, isActive: true),
          _navItem(
            Icons.people_outline,
            "Dosen",
            Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DosenPage()),
              );
            },
          ),
          _navItem(
            Icons.calendar_today,
            "Jadwal Kuliah",
            Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JadwalPage()),
              );
            },
          ),
          _navItem(
            Icons.assignment_ind,
            "KRS Mahasiswa",
            Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KrsPage()),
              );
            },
          ),
          _navItem(
            Icons.school,
            "Mahasiswa",
            Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MahasiswaPage()),
              );
            },
          ),
          _navItem(
            Icons.book,
            "Mata Kuliah",
            Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MataKuliahPage()),
              );
            },
          ),
          _navItem(
            Icons.room,
            "Ruangan",
            Colors.grey,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RuanganPage()),
              );
            },
          ),
          _navItem(
            Icons.event,
            "Semester",
            Colors.grey,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SemesterPage()),
              );
            },
          ),
          _navItem(
            Icons.admin_panel_settings,
            "Admin",
            Colors.grey,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),

          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Sign out",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk item menu samping
  Widget _navItem(
    IconData icon,
    String title,
    Color color, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.amber : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isActive ? Colors.amber : Colors.white),
      ),
      tileColor: isActive
          ? Colors.amber.withValues(alpha: 0.1)
          : Colors.transparent,
      onTap: onTap,
    );
  }

  Widget _buildWelcomeWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: Text(_adminName[0].toUpperCase()),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    _adminName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
        _statCards("Mahasiswa", _totalMahasiswa, Icons.school, Colors.blue),
        _statCards("Dosen", _totalDosen, Icons.people_outline, Colors.orange),
        _statCards("Mata Kuliah", _totalMataKuliah, Icons.book, Colors.green),
        _statCards(
          "Jadwal Kuliah",
          _totalJadwal,
          Icons.calendar_today,
          Colors.purple,
        ),
        _statCards("Ruangan", _totalRuangan, Icons.room, Colors.red),
        _statCards("Semester", _totalSemester, Icons.event, Colors.teal),
      ],
    );
  }

  Widget _statCards(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
