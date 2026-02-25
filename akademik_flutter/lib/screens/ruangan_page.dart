import 'package:flutter/material.dart';
import '../services/ruangan_service.dart';
import 'create_ruangan_page.dart';
import 'edit_ruangan_page.dart';

class RuanganPage extends StatefulWidget {
  const RuanganPage({super.key});

  @override
  State<RuanganPage> createState() => _RuanganPageState();
}

class _RuanganPageState extends State<RuanganPage> {
  final RuanganService _ruanganService = RuanganService();
  late Future<List<dynamic>> _ruanganFuture;

  @override
  void initState() {
    super.initState();
    _ruanganFuture = _ruanganService.getRuanganList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _ruanganFuture = _ruanganService.getRuanganList();
    });
    await _ruanganFuture;
  }

  Future<void> _confirmDelete(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Hapus Ruangan?',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Hapus ruangan $nama? Pastikan ruangan ini tidak sedang dipakai di jadwal.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _ruanganService.deleteRuangan(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruangan dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Data KRS", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // --- PERBAIKAN 2: REFRESH SETELAH TAMBAH ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRuanganPage()),
          );

          if (result == true) {
            _refreshData();
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _ruanganFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            if (snapshot.hasError)
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(
                child: Text(
                  "Belum ada ruangan.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
              
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                final id = item['id'].toString();
                final nama = item['nama'] ?? '-';
                final gedung = item['gedung'] ?? '-';
                final kapasitas = item['kapasitas']?.toString() ?? '0';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.meeting_room, color: Colors.white),
                    ),
                    title: Text(
                      nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$gedung • Kapasitas: $kapasitas",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditRuanganPage(ruanganData: item),
                              ),
                            );
                            if (result == true) _refreshData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(id, nama),
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
