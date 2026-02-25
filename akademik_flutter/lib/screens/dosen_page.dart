import 'package:flutter/material.dart';
import '../services//dosen_service.dart';
import 'create_dosen_page.dart';
import 'edit_dosen_page.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  // Panggil Service Jadwal
  final DosenService _dosenService = DosenService();
  // Siapkan variabel untuk menampung proses pengambilan data
  late Future<List<dynamic>> _dosenList;

  @override
  void initState() {
    super.initState();
    _dosenList = _dosenService.getDosenList();
  }

  // Fungsi Refresh Tarik Layar
  Future<void> _refreshData() async {
    setState(() {
      _dosenList = _dosenService.getDosenList();
    });
    await _dosenList;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String namaDosen,
  ) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Apakah anda yakin ingi menghapus dosen $namaDosen beserta akun loginnya? Tindakan ini tidak dapat dibatalkan',
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
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dosenService.deleteDosen(id);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosen berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateDosenPage()),
          );

          if (result == true) {
            setState(() {
              _dosenList = _dosenService.getDosenList();
            });
          }
        },
      ),
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Data Dosen", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _dosenList,
          builder: (context, snapshot) {
            // KONDISI 1: Jika loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            }
            // KONDISI 2: Jika API error / gagal nyambung
            else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            // KONDISI 3: Jika data kosong di database
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Belum ada data dosen.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            // KONDISI 4: Jika DATA BERHASIL DIDAPAT!
            final dataDosen = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataDosen.length,
              itemBuilder: (context, index) {
                final dosen = dataDosen[index];
                final String idDosen = dosen['id'].toString();
                final String namaDosen = dosen['user']?['name'] ?? 'Tanpa nama';

                // Tampilan per baris
                return Card(
                  color: const Color(0xFF1F2937),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    // Mengambil Nama dari relasi user
                    title: Text(
                      dosen['user']['name'] ?? 'Tanpa Nama',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Menampilkan NIP dan Gelar
                    subtitle: Text(
                      "NIP: ${dosen['nip']} • Gelar: ${dosen['gelar'] ?? '-'}",
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
                                    EditDosenPage(dosenData: dosen),
                              ),
                            );
                            if (result == true) {
                              _refreshData();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _confirmDelete(context, idDosen, namaDosen);
                          },
                        ),
                      ],
                    ),
                      onTap: () {
                        // Nanti kita bisa buat fitur klik untuk lihat detail
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "No HP: ${dosen['no_hp'] ?? 'Tidak ada'}",
                            ),
                          ),
                        );
                      },
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
