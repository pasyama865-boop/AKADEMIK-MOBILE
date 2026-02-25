import 'package:flutter/material.dart';
import '../services/krs_service.dart';
import 'create_krs_page.dart';
import 'edit_krs_page.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  final KrsService _krsService = KrsService();
  late Future<List<dynamic>> _krsFuture;

  @override
  void initState() {
    super.initState();
    _krsFuture = _krsService.getKrsList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _krsFuture = _krsService.getKrsList();
    });
    await _krsFuture;
  }

  Future<void> _confirmDelete(BuildContext context, String id, String namaMhs, String matkul) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Konfirmasi Hapus KRS', style: TextStyle(color: Colors.red)),
        content: Text('Hapus KRS mata kuliah $matkul untuk mahasiswa $namaMhs?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Kembali', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _krsService.deleteKrs(id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KRS berhasil dibatalkan'), backgroundColor: Colors.green));
        _refreshData(); 
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
            floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateKrsPage()),
          );

          if (result == true) {
            _refreshData();
          }
        },
      ),
      // -------------------------------------------

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _krsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data KRS.", style: TextStyle(color: Colors.grey)));
            }

            final krsList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: krsList.length,
              itemBuilder: (context, index) {
                final item = krsList[index];
                
                final idKrs = item['id'].toString();
                final namaMhs = item['mahasiswa']?['user']?['name'] ?? 'Tanpa Nama';
                final nimMhs = item['mahasiswa']?['nim'] ?? '-';
                final namaMatkul = item['jadwal']?['mata_kuliah']?['nama_matkul'] ?? 'Matkul ?';
                final hari = item['jadwal']?['hari'] ?? '-';
                final jam = (item['jadwal']?['jam_mulai'] != null && item['jadwal']['jam_mulai'].length >= 5)
                    ? item['jadwal']['jam_mulai'].substring(0, 5)
                    : '-';

                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.assignment_ind, color: Colors.white), 
                    ),
                    title: Text(
                      namaMhs,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "$namaMatkul • $hari ($jam)",
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
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
                                builder: (context) => EditKrsPage(krsData: item),
                              ),
                            );
                            if (result == true) {
                              _refreshData();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(context, idKrs, namaMhs, nimMhs ,);
                          },
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