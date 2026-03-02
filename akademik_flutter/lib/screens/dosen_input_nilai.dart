import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/dosen_dashboard_service.dart';

class DosenInputNilai extends StatefulWidget {
  final String jadwalId;
  final String namaMatkul;

  const DosenInputNilai({
    super.key,
    required this.jadwalId,
    required this.namaMatkul,
  });

  @override
  State<DosenInputNilai> createState() => _DosenInputNilaiState();
}

class _DosenInputNilaiState extends State<DosenInputNilai> {
  final DosenDashboardService _service = DosenDashboardService();
  List<dynamic> _mahasiswaKelas = [];
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
      final list = await _service.getKelasMahasiswa(widget.jadwalId);
      setState(() {
        _mahasiswaKelas = list;
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

  Future<void> _inputNilaiMhs(
    String krsId,
    String nama,
    String currentNilai,
  ) async {
    String? selectedNilai = currentNilai.isEmpty ? null : currentNilai;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String? modalNilai = selectedNilai;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                "Input Nilai",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mahasiswa: $nama",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    initialValue: modalNilai,
                    decoration: InputDecoration(
                      labelText: 'Pilih Nilai (A-E)',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    items: ['A', 'B', 'C', 'D', 'E'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setModalState(() {
                        modalNilai = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, modalNilai),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _service.inputNilai(krsId, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Nilai berhasil disimpan"),
              backgroundColor: AppColors.success,
            ),
          );
          _fetchMahasiswa(); // reload data
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Nilai: ${widget.namaMatkul}",
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
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
          : _mahasiswaKelas.isEmpty
          ? const Center(
              child: Text(
                "Belum ada mahasiswa di kelas ini.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchMahasiswa,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _mahasiswaKelas.length,
                itemBuilder: (context, index) {
                  final mhs = _mahasiswaKelas[index];
                  final krsId = (mhs['krs_id'] ?? '').toString();
                  final nama = mhs['nama'] ?? '-';
                  final nim = mhs['nim'] ?? '-';
                  final nilai = mhs['nilai_akhir'] ?? '';

                  return Card(
                    color: AppColors.cardBackground,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        nama,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        nim,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: nilai.toString().isNotEmpty
                              ? AppColors.success
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            _inputNilaiMhs(krsId, nama, nilai.toString()),
                        child: Text(
                          nilai.toString().isNotEmpty
                              ? "Nilai: $nilai"
                              : "Input Nilai",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
