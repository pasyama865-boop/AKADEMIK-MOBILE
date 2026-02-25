import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'jadwal_page.dart';
import 'login.dart';
import 'profile.dart';
import 'nilai.dart';
import 'krs_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Fungsi logout
  void _logout(BuildContext context) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Keluar"),
          ),
        ],
      ),
    );
    // Kalau pilih batal, berhenti di sini
    if (confirm != true) return;
    // Proses logout
    final authService = AuthService();
    // Ini kunci hapus token dari memori hp
    await authService.logout();

    if (context.mounted) {
      // Lempar ke halaman login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berhasil logout!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Mahasiswa"),
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu sambutan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Mahasiswa!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Selamat datang di Sistem akademik",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grid Menu Kotak-kotak
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    Icons.calendar_today,
                    "Jadwal Kuliah",
                    Colors.orange,
                  ),
                  _buildMenuCard(
                    context,
                    Icons.list_alt,
                    "Kartu Studi",
                    Colors.green,
                  ),
                  _buildMenuCard(
                    context,
                    Icons.school,
                    "Nilai / Transkrip",
                    Colors.purple,
                  ),
                  _buildMenuCard(
                    context,
                    Icons.person,
                    "Profil Saya",
                    Colors.teal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Membuat kartu menu agar kode lebih rapih
  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (label == "Profil Saya") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (label.contains("krs") || label.contains("Kartu Studi")) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KrsPage()),
            );
          } else if (label == "Nilai / Transkrip") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NilaiScreen()),
            );
          } else if (label == "Jadwal Kuliah") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JadwalPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Menu $label akan segera hadir!")),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
