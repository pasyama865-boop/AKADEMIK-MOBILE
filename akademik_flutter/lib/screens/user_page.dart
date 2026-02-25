import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'create_admin_page.dart';
import 'edit_admin_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  late Future<List<dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi awal saat halaman dibuka
    _userFuture = _userService.getUserList();
  }

  // 2. Fungsi sakti untuk memotret ulang data
  Future<void> _refreshData() async {
    setState(() {
      _userFuture = _userService.getUserList();
    });
    await _userFuture;
  }

  Future<void> _confirmDelete(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Hapus Akses Admin?', style: TextStyle(color: Colors.red)),
        content: Text('Hapus akses admin secara permanen untuk "$nama"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin dihapus'), backgroundColor: Colors.green));
        
        // 3. Panggil fungsi sakti setelah sukses menghapus
        _refreshData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(title: const Text("Data Admin Sistem", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          // 4. Tunggu oleh-oleh (nilai true) dari halaman sebelah
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAdminPage()));
          
          // 5. Jika ada data baru, jepret ulang!
          if (result == true) {
            _refreshData();
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber, backgroundColor: const Color(0xFF1F2937),
        
        // 6. KEMBALI MENGGUNAKAN FUTURE BUILDER
        child: FutureBuilder<List<dynamic>>(
          future: _userFuture,
          builder: (context, snapshot) {
            // State: Sedang Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }
            
            // State: Jika Error
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            
            // State: Jika Kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text("Belum ada data admin.", style: TextStyle(color: Colors.grey))),
                ],
              );
            }

            // State: Jika Ada Data
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                final id = item['id'].toString();
                final nama = item['name'] ?? '-';
                final email = item['email'] ?? '-';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: const Text("ADMIN", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAdminPage(userData: item)));
                                if (result == true) _refreshData();
                              },
                            ),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(id, nama)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}