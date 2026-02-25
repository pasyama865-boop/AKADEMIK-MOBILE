import 'package:flutter/material.dart';
import '../services/mahasiswa_service.dart';
import 'create_mahasiswa_page.dart';
import 'edit_mahasiswa_page.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final MahasiswaService _mahasiswaService = MahasiswaService();
  late Future<List<dynamic>> _mahasiswaFuture;

  @override
  void initState() {
    super.initState();
    _mahasiswaFuture = _mahasiswaService.getMahasiswaList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _mahasiswaFuture = _mahasiswaService.getMahasiswaList();
    });
    await _mahasiswaFuture;
  }

  // FUNGSI KONFIRMASI & HAPUS
  Future<void> _confirmDelete(BuildContext context, String id, String nama) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: Colors.red)),
        content: Text('Hapus mahasiswa $nama beserta akun login-nya?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _mahasiswaService.deleteMahasiswa(id);
        if (!context.mounted) return; // Penjaga Pintu Asinkron
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mahasiswa berhasil dihapus'), backgroundColor: Colors.green),
        );
        _refreshData();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Data Mahasiswa", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // TOMBOL TAMBAH MAHASISWA 
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMahasiswaPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _mahasiswaFuture,
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            } 
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            } 
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data Mahasiswa.", style: TextStyle(color: Colors.grey)));
            }

            final mahasiswaList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mahasiswaList.length,
              itemBuilder: (context, index) {
                final item = mahasiswaList[index];

                final idMhs = item['id'].toString(); 
                final nama = item['user']?['name'] ?? 'Tanpa Nama';
                final nim = item['nim'] ?? '-';
                final jurusan = item['jurusan'] ?? '-';
                final angkatan = item['angkatan']?.toString() ?? '-';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[900],
                      child: const Icon(Icons.person_outline, color: Colors.white),
                    ),
                    title: Text(
                      nama,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green[800], borderRadius: BorderRadius.circular(4)),
                            child: Text(nim, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(height: 6),
                          Text("Jurusan: $jurusan", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text("Angkatan: $angkatan", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    // TOMBOL EDIT DAN HAPUS
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditMahasiswaPage(mahasiswaData: item)),
                            );
                            if (result == true) _refreshData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, idMhs, nama),
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