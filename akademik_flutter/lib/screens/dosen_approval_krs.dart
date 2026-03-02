import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/dosen_dashboard_service.dart';

class DosenApprovalKrs extends StatefulWidget {
  const DosenApprovalKrs({super.key});

  @override
  State<DosenApprovalKrs> createState() => _DosenApprovalKrsState();
}

class _DosenApprovalKrsState extends State<DosenApprovalKrs> {
  final DosenDashboardService _service = DosenDashboardService();
  List<dynamic> _mahasiswaList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMahasiswa();
  }

  Future<void> _fetchMahasiswa() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.getMahasiswaBimbingan();
      setState(() {
        _mahasiswaList = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveKrs(String idMahasiswa, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Approve KRS",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "Setujui semua KRS $nama yang masih pending?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Setujui",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.approveKrsMahasiswa(idMahasiswa);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil menyetujui KRS"),
            backgroundColor: AppColors.success,
          ),
        );
        _fetchMahasiswa();
      }
    } catch (e) {
      if (mounted) {
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
          "Approval KRS Bimbingan",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Text(
                "Error: $_error",
                style: const TextStyle(color: AppColors.error),
              ),
            )
          : _mahasiswaList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada mahasiswa bimbingan.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchMahasiswa,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _mahasiswaList.length,
                itemBuilder: (context, index) {
                  final mhs = _mahasiswaList[index];
                  final id = (mhs['id'] ?? '').toString();
                  final nama = mhs['nama'] ?? '-';
                  final nim = mhs['nim'] ?? '-';
                  final statusWarning = mhs['status_warning'] ?? 'Aman';
                  final pendingCount = mhs['krs_pending_count'] ?? 0;

                  return Card(
                    color: AppColors.cardBackground,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      nim,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusWarning == 'Aman'
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  statusWarning == 'Aman'
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: statusWarning == 'Aman'
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    statusWarning,
                                    style: TextStyle(
                                      color: statusWarning == 'Aman'
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$pendingCount KRS Pending",
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (pendingCount > 0)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _approveKrs(id, nama),
                                  child: const Text(
                                    "Approve Semua",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
