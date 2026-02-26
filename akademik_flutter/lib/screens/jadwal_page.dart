import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/jadwal.dart';
import '../services/jadwal_service.dart';
import 'create_jadwal_page.dart';
import 'edit_jadwal_page.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final JadwalService _jadwalService = JadwalService();
  late Future<List<Jadwal>> _jadwalFuture;

  @override
  void initState() {
    super.initState();
    _jadwalFuture = _jadwalService.getJadwal();
  }

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
        backgroundColor: AppColors.surface,
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(
          'Hapus jadwal mata kuliah $matkul?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(color: AppColors.textPrimary),
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
            backgroundColor: AppColors.success,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateJadwalPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Jadwal Kuliah",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: FutureBuilder<List<Jadwal>>(
          future: _jadwalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Belum ada jadwal kuliah.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final jadwalList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final jadwal = jadwalList[index];

                return Card(
                  color: AppColors.cardBackground,
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
                                jadwal.hari,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              jadwal.namaSemester,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jadwal.namaMatkul,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              jadwal.jamFormatted,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.room,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              jadwal.namaRuangan,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.blueGrey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  jadwal.namaDosen,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.info,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditJadwalPage(
                                          jadwalData: {
                                            'id': jadwal.id,
                                            'mata_kuliah_id':
                                                jadwal.mataKuliahId,
                                            'dosen_id': jadwal.dosenId,
                                            'semester_id': jadwal.semesterId,
                                            'ruangan_id': jadwal.ruanganId,
                                            'hari': jadwal.hari,
                                            'jam_mulai': jadwal.jamMulai,
                                            'jam_selesai': jadwal.jamSelesai,
                                            'kuota': jadwal.kuota,
                                          },
                                        ),
                                      ),
                                    );
                                    if (result == true) _refreshData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _confirmDelete(
                                    context,
                                    jadwal.id,
                                    jadwal.namaMatkul,
                                  ),
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
