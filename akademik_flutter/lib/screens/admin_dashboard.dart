import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/kartu_statistik.dart';
import '../widgets/kartu_menu.dart';
import '../widgets/loading_berkedip.dart';
import 'dosen_page.dart';
import 'matakuliah_page.dart';
import 'ruangan_page.dart';
import 'semester_page.dart';
import 'jadwal_page.dart';
import 'krs_page.dart';
import 'user_page.dart';
import 'login.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _adminStats;
  bool _isLoading = true;
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _authService.getProfile(),
        _authService.getAdminStats(),
      ]);

      if (mounted) {
        final profile = results[0] as Map<String, dynamic>?;
        if (profile != null) {
          name = profile['name'] ?? "";
          email = profile['email'] ?? "";
        }

        setState(() {
          _adminStats = results[1] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          "Logout",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Yakin ingin Keluar??",
          style: GoogleFonts.inter(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Logout",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getStatValue(String key) {
    if (_adminStats == null) return "0";
    return _adminStats![key]?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 30,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang,",
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                          ),
                          onPressed: () => _logout(context),
                          tooltip: 'Logout',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Overview Sistem",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _isLoading
                      ? const ShimmerStatGrid()
                      : GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatCard(
                              title: "Total Mahasiswa",
                              value: _getStatValue('total_mahasiswa'),
                              icon: Icons.people_alt,
                              gradientColors: const [
                                Color(0xFF4F46E5),
                                Color(0xFF818CF8),
                              ],
                            ),
                            StatCard(
                              title: "Total Dosen",
                              value: _getStatValue('total_dosen'),
                              icon: Icons.badge,
                              gradientColors: const [
                                Color(0xFF059669),
                                Color(0xFF34D399),
                              ],
                            ),
                            StatCard(
                              title: "Total Matkul",
                              value: _getStatValue('total_matakuliah'),
                              icon: Icons.library_books,
                              gradientColors: const [
                                Color(0xFFD97706),
                                Color(0xFFFBBF24),
                              ],
                            ),
                            StatCard(
                              title: "Total Ruangan",
                              value: _getStatValue('total_ruangan'),
                              icon: Icons.meeting_room,
                              gradientColors: const [
                                Color(0xFFDC2626),
                                Color(0xFFF87171),
                              ],
                            ),
                            StatCard(
                              title: "Total Kelas/KRS",
                              value: _getStatValue('total_krs'),
                              icon: Icons.fact_check,
                              gradientColors: const [
                                Color(0xFF7C3AED),
                                Color(0xFFA78BFA),
                              ],
                            ),
                            StatCard(
                              title: "Total Admin",
                              value: _getStatValue('total_admin'),
                              icon: Icons.admin_panel_settings,
                              gradientColors: const [
                                Color(0xFF2563EB),
                                Color(0xFF60A5FA),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 35,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dashboard_customize,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Panel Manajemen",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MenuCard(
                      title: "Manajemen Mahasiswa",
                      icon: Icons.people_rounded,
                      color: Colors.indigoAccent,
                      badge: _isLoading
                          ? "..."
                          : "${_getStatValue('total_mahasiswa')} Mhs",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MataKuliahPage(),
                        ),
                      ).then((_) => _loadAllData()),
                    ),
                    const SizedBox(height: 12),
                    MenuCard(
                      title: "Manajemen Dosen",
                      icon: Icons.badge_rounded,
                      color: Colors.greenAccent,
                      badge: _isLoading
                          ? "..."
                          : "${_getStatValue('total_dosen')} Dsn",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DosenPage()),
                      ).then((_) => _loadAllData()),
                    ),
                    const SizedBox(height: 12),
                    MenuCard(
                      title: "Jadwal Perkuliahan",
                      icon: Icons.calendar_month_rounded,
                      color: Colors.redAccent,
                      badge: _isLoading
                          ? "..."
                          : "${_getStatValue('total_jadwal')} Jdwl",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JadwalPage()),
                      ).then((_) => _loadAllData()),
                    ),
                    const SizedBox(height: 12),
                    MenuCard(
                      title: "Kartu Rencana Studi (KRS)",
                      icon: Icons.post_add_rounded,
                      color: Colors.purpleAccent,
                      badge: _isLoading
                          ? "..."
                          : "${_getStatValue('total_krs')} KRS",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KrsPage()),
                      ).then((_) => _loadAllData()),
                    ),
                    const SizedBox(height: 12),
                    MenuCard(
                      title: "Data Master Lainnya",
                      icon: Icons.folder_special_rounded,
                      color: Colors.blueAccent,
                      onTap: () => _tampilkanDialogMaster(context),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tampilkanDialogMaster(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Data Master Lainnya",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MenuCard(
                title: "Manajemen Ruangan",
                icon: Icons.door_front_door_rounded,
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RuanganPage()),
                  ).then((_) => _loadAllData());
                },
              ),
              const SizedBox(height: 12),
              MenuCard(
                title: "Manajemen Semester",
                icon: Icons.date_range_rounded,
                color: Colors.pinkAccent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SemesterPage()),
                  ).then((_) => _loadAllData());
                },
              ),
              const SizedBox(height: 12),
              MenuCard(
                title: "Manajemen Admin",
                icon: Icons.admin_panel_settings_rounded,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserPage()),
                  ).then((_) => _loadAllData());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
