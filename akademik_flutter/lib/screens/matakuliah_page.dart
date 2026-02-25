import 'package:flutter/material.dart';
import '../services/matakuliah_service.dart';
import 'create_matakuliah_page.dart';
import 'edit_matakuliah_page.dart';

class MataKuliahPage extends StatefulWidget {
  const MataKuliahPage({super.key});

  @override
  State<MataKuliahPage> createState() => _MataKuliahPageState();
}

class _MataKuliahPageState extends State<MataKuliahPage> {
  final MatakuliahService _matkulService = MatakuliahService();
  late Future<List<dynamic>> _matkulFuture;

  @override
  void initState() {
    super.initState();
    _matkulFuture = _matkulService.getMataKuliahList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _matkulFuture = _matkulService.getMataKuliahList();
    });
    await _matkulFuture;
  }

  // FUNGSI KONFIRMASI & HAPUS
  Future<void> _confirmDelete(BuildContext context, String id, String nama) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: Colors.red)),
        content: Text('Hapus matakuliah $nama beserta akun login-nya?', style: const TextStyle(color: Colors.white)),
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
        await _matkulService.deleteMataKuliah(id);
        if (!context.mounted) return; 
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
        title: const Text("Data Mata Kuliah", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // TOMBOL TAMBAH matakuliah 
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMataKuliahPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _matkulFuture,
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            } 
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            } 
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data Mata Kuliah.", style: TextStyle(color: Colors.grey)));
            }

            final matkulList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matkulList.length,
              itemBuilder: (context, index) {
                final item = matkulList[index];

                // PEMETAAN DATA 
                final idMtk = item['id'].toString();
                final kode = item['kode_matkul'] ?? '-';
                final nama = item['nama_matkul'] ?? 'Mata Kuliah Tidak Diketahui';
                final sks = item['sks']?.toString() ?? '0';
                final semester = item['semester_paket']?.toString() ?? '-';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[900],
                        child: const Icon(Icons.menu_book, color: Colors.white),
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
                          child: Text(kode, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 6),
                        Text("$sks SKS", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        Text("$semester SEMESTER", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditMataKuliahPage(data: item)),
                            );
                            if (result == true) _refreshData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, idMtk, nama),
                        ),
                      ],
                    ),),
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