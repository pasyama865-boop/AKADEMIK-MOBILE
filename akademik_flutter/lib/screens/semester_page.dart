import 'package:flutter/material.dart';
import '../services/semester_service.dart';
import 'create_semester_page.dart';
import 'edit_semester_page.dart';


class SemesterPage extends StatefulWidget {
  const SemesterPage({super.key});

  @override
  State<SemesterPage> createState() => _SemesterPageState();
}

class _SemesterPageState extends State<SemesterPage> {
  final SemesterService _semesterService = SemesterService();
  late Future<List<dynamic>> _semesterFuture;

  @override
  void initState() {
    super.initState();
    _semesterFuture = _semesterService.getSemesterList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _semesterFuture = _semesterService.getSemesterList();
    });
    await _semesterFuture;
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
        await _semesterService.deleteSemester(id);
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
        title: const Text("Data Ruangan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSemesterPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _semesterFuture,
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            } 
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            } 
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data Ruangan.", style: TextStyle(color: Colors.grey)));
            }

            final ruanganList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ruanganList.length,
              itemBuilder: (context, index) {
                final item = ruanganList[index];

                // Data diambil langsung secara mentah, ditangani jika null (??)
                final namaRuangan = item['nama'] ?? 'Ruang ?';
                final gedung = item['gedung'] ?? '-';
                final kapasitas = item['kapasitas']?.toString() ?? '0';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[900],
                      child: const Icon(Icons.room_service, color: Colors.white),
                    ),
                    title: Text(
                      namaRuangan,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green[800], borderRadius: BorderRadius.circular(4)),
                            child: Text(gedung, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(height: 6),
                          Text("Kapasitas: $kapasitas", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          
                        ],
                      ),
                    ),
                    // Trailing digunakan untuk menaruh Kapasitas di sebelah kanan
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditSemesterPage(semesterData: item)),
                            );
                            if (result == true) _refreshData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, item['id'].toString(), namaRuangan),
                        ),
                      ],
                    ),
                  ) 
                );
              },
            );
          },
        ),
      ),
    );
  }
}