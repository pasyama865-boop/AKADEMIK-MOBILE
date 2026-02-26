import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/mahasiswa.dart';
import '../models/jadwal.dart';
import '../services/krs_service.dart';
import '../services/mahasiswa_service.dart';
import '../services/jadwal_service.dart';

class CreateKrsPage extends StatefulWidget {
  const CreateKrsPage({super.key});

  @override
  State<CreateKrsPage> createState() => _CreateKrsPageState();
}

class _CreateKrsPageState extends State<CreateKrsPage> {
  final _formKey = GlobalKey<FormState>();
  final KrsService _krsService = KrsService();

  String? _selectedMahasiswa;
  String? _selectedJadwal;

  List<Mahasiswa> _mahasiswaList = [];
  List<Jadwal> _jadwalList = [];

  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MahasiswaService().getMahasiswaList(),
        JadwalService().getJadwal(),
      ]);
      setState(() {
        _mahasiswaList = results[0] as List<Mahasiswa>;
        _jadwalList = results[1] as List<Jadwal>;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _krsService.createKrs(_selectedMahasiswa!, _selectedJadwal!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KRS berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Input KRS",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMahasiswa,
                    items: _mahasiswaList
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              "${m.nim} - ${m.namaUser}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMahasiswa = v),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Pilih Mahasiswa",
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v == null ? 'Wajib pilih' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedJadwal,
                    isExpanded: true,
                    items: _jadwalList
                        .map(
                          (j) => DropdownMenuItem(
                            value: j.id,
                            child: Text(
                              "${j.namaMatkul} | ${j.hari} ${j.jamFormatted}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedJadwal = v),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Pilih Jadwal",
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v == null ? 'Wajib pilih' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isSaving ? null : _submitData,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Simpan KRS",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
