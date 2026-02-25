import 'package:flutter/material.dart';
import '../services/jadwal_service.dart';
import 'create_jadwal_page.dart';
import 'edit_jadwal_page.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  // Panggil Service Jadwal
  final JadwalService _jadwalService = JadwalService();
  // Siapkan variabel untuk menampung proses pengambilan data
  late Future<List<dynamic>> _jadwalFuture;

  @override
  void initState() {
    super.initState();
    _jadwalFuture = _jadwalService.getJadwal();
  }

  // Fungsi Refresh Tarik Layar
  Future<void> _refreshData() async {
    setState(() {
      _jadwalFuture = _jadwalService.getJadwal();
    });
    await _jadwalFuture;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String matkul,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Hapus jadwal mata kuliah $matkul?',
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
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _jadwalService.deleteJadwal(id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
            MaterialPageRoute(builder: (context) => const CreateJadwalPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      // 1. TEMA GELAP
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          "Jadwal Kuliah",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1F2937),
        child: FutureBuilder<List<dynamic>>(
          future: _jadwalFuture,
          builder: (context, snapshot) {
            // KONDISI 1: Jika loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            }

            // KONDISI 2: Jika API error / gagal nyambung
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // KONDISI 3: Jika data kosong di database
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Belum ada jadwal kuliah.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            // KONDISI 4: Jika DATA BERHASIL DIDAPAT!
            final jadwalList = snapshot.data!;
            debugPrint("isi paket daru laravel: $jadwalList");

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final item = jadwalList[index];
                // Ambil id mata kuliah
                final idJadwal = item['id'].toString();
                // Ambil nama mata kuliah
                final namaMatkul =
                    item['mata_kuliah']?['nama_matkul'] ?? 'Mata Kuliah ?';
                // Ambil nama dosen
                final namaDosen = item['dosen']?['name'] ?? 'Dosen ?';
                // Ambil nama semester
                final namaSemester = item['semester']?['nama'] ?? 'Semester ?';
                // Ambil nama ruangan
                final namaRuangan = item['ruangan']?['nama'] ?? 'Ruangan ?';
                // Ambil waktu dan hari
                final hari = item['hari'] ?? '-';
                final jam =
                    "${item['jam_mulai'] ?? ''} - ${item['jam_selesai'] ?? ''}";

                // Tampilan per baris
                return Card(
                  color: const Color(0xFF1F2937), 
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hari,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Teks Semester
                            Text(
                              namaSemester,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Nama Mata Kuliah
                        Text(
                          namaMatkul,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Jam & Ruangan
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              jam,
                              style: const TextStyle(color: Colors.amber),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.room,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              namaRuangan,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 20),
                        // Nama Dosen
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon dosen
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.blueGrey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  namaDosen,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Edit 
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditJadwalPage(jadwalData: item),
                                      ),
                                    );
                                    if (result == true) {
                                      _refreshData();
                                    }
                                  },
                                ),
                                // Tombol Hapus 
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(context, idJadwal, namaMatkul);
                                  },
                                ),
                              ],
                            ),                            
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
