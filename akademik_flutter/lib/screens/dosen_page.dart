import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/dosen.dart';
import '../services/dosen_service.dart';
import 'create_dosen_page.dart';
import 'edit_dosen_page.dart';

class DosenPage extends StatefulWidget {
  const DosenPage({super.key});

  @override
  State<DosenPage> createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  final DosenService _dosenService = DosenService();
  late Future<List<Dosen>> _dosenList;

  @override
  void initState() {
    super.initState();
    _dosenList = _dosenService.getDosenList();
  }

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
        backgroundColor: AppColors.surface,
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(
          'Apakah anda yakin ingin menghapus dosen $namaDosen beserta akun loginnya? Tindakan ini tidak dapat dibatalkan',
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
              style: TextStyle(
                color: AppColors.textPrimary,
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
            backgroundColor: AppColors.success,
          ),
        );
        _refreshData();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
            MaterialPageRoute(builder: (context) => CreateDosenPage()),
          );
          if (result == true) _refreshData();
        },
      ),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Data Dosen",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: FutureBuilder<List<Dosen>>(
          future: _dosenList,
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
                  "Belum ada data dosen.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final dataDosen = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataDosen.length,
              itemBuilder: (context, index) {
                final dosen = dataDosen[index];

                return Card(
                  color: AppColors.cardBackground,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: AppColors.textPrimary),
                    ),
                    title: Text(
                      dosen.namaLengkap,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "NIP: ${dosen.nip} • Gelar: ${dosen.gelar ?? '-'}",
                      style: const TextStyle(color: AppColors.textSecondary),
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
                                builder: (context) => EditDosenPage(
                                  dosenData: {
                                    'id': dosen.id,
                                    'user_id': dosen.userId,
                                    'nip': dosen.nip,
                                    'gelar': dosen.gelar,
                                    'no_hp': dosen.noHp,
                                    'user': {
                                      'name': dosen.namaLengkap,
                                      'email': dosen.email,
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
                            dosen.id,
                            dosen.namaLengkap,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("No HP: ${dosen.noHp ?? 'Tidak ada'}"),
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
