import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/krs.dart';
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
  late Future<List<Krs>> _krsFuture;

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

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String namaMhs,
    String matkul,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Konfirmasi Hapus KRS',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(
          'Hapus KRS mata kuliah $matkul untuk mahasiswa $namaMhs?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Kembali',
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
        await _krsService.deleteKrs(id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KRS berhasil dibatalkan'),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Data KRS",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateKrsPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: FutureBuilder<List<Krs>>(
          future: _krsFuture,
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
                  "Belum ada data KRS.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final krsList = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: krsList.length,
              itemBuilder: (context, index) {
                final krs = krsList[index];

                final jamDisplay = krs.jamMulai.length >= 5
                    ? krs.jamMulai.substring(0, 5)
                    : '-';

                return Card(
                  color: AppColors.cardBackground,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.assignment_ind,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    title: Text(
                      krs.namaMahasiswa,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${krs.namaMatkul} • ${krs.hari} ($jamDisplay)",
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.info),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditKrsPage(
                                  krsData: {
                                    'id': krs.id,
                                    'mahasiswa_id': krs.mahasiswaId,
                                    'jadwal_id': krs.jadwalId,
                                    'mahasiswa': {
                                      'user': {'name': krs.namaMahasiswa},
                                      'nim': krs.nimMahasiswa,
                                    },
                                    'jadwal': {
                                      'mata_kuliah': {
                                        'nama_matkul': krs.namaMatkul,
                                      },
                                    },
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
                            krs.id,
                            krs.nimMahasiswa,
                            krs.namaMahasiswa,
                          ),
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
