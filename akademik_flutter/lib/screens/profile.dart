import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: authService.getProfile(), 
        builder: (context, snapshot) {
          // 1. SEDANG LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. JIKA ERROR
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. JIKA SUKSES
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Kartu Info
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Nama Lengkap"),
                      subtitle: Text(user['name'] ?? '-'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text("Email"),
                      subtitle: Text(user['email'] ?? '-'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text("NIM / NIP"),
                      subtitle: Text(user['nim_nip'] ?? '-'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text("Peran (Role)"),
                      subtitle: Text(user['role'] ?? '-'),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Data tidak ditemukan"));
        },
      ),
    );
  }
}