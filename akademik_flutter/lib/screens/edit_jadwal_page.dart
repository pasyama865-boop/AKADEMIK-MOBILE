import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/mata_kuliah.dart';
import '../models/dosen.dart';
import '../models/ruangan.dart';
import '../models/semester.dart';
import '../services/jadwal_service.dart';
import '../services/matakuliah_service.dart';
import '../services/dosen_service.dart';
import '../services/ruangan_service.dart';
import '../services/semester_service.dart';

class EditJadwalPage extends StatefulWidget {
  final Map<String, dynamic> jadwalData;
  const EditJadwalPage({super.key, required this.jadwalData});

  @override
  State<EditJadwalPage> createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final JadwalService _jadwalService = JadwalService();
  final _kuotaController = TextEditingController();
  final _jamMulaiController = TextEditingController();
  final _jamSelesaiController = TextEditingController();

  String? _selectedMatkul;
  String? _selectedDosen;
  String? _selectedRuangan;
  String? _selectedSemester;
  String? _selectedHari;

  List<MataKuliah> _matkulList = [];
  List<Dosen> _dosenList = [];
  List<Ruangan> _ruanganList = [];
  List<Semester> _semesterList = [];

  bool _isLoadingData = true;
  bool _isSaving = false;

  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _setInitialData();
    _loadDropdownData();
  }

  void _setInitialData() {
    final jadwal = widget.jadwalData;
    _selectedMatkul = jadwal['mata_kuliah_id']?.toString();
    _selectedDosen = jadwal['dosen_id']?.toString();
    _selectedRuangan = jadwal['ruangan_id']?.toString();
    _selectedSemester = jadwal['semester_id']?.toString();
    _selectedHari = jadwal['hari'];
    _kuotaController.text = jadwal['kuota']?.toString() ?? '';
    final jamMulai = jadwal['jam_mulai']?.toString() ?? '';
    _jamMulaiController.text = jamMulai.length >= 5
        ? jamMulai.substring(0, 5)
        : jamMulai;
    final jamSelesai = jadwal['jam_selesai']?.toString() ?? '';
    _jamSelesaiController.text = jamSelesai.length >= 5
        ? jamSelesai.substring(0, 5)
        : jamSelesai;
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        MatakuliahService().getMataKuliahList(),
        DosenService().getDosenList(),
        RuanganService().getRuanganList(),
        SemesterService().getSemesterList(),
      ]);
      setState(() {
        _matkulList = results[0] as List<MataKuliah>;
        _dosenList = results[1] as List<Dosen>;
        _ruanganList = results[2] as List<Ruangan>;
        _semesterList = results[3] as List<Semester>;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data pilihan'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.info,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _jadwalService.updateJadwal(widget.jadwalData['id'].toString(), {
        'mata_kuliah_id': _selectedMatkul,
        'dosen_id': _selectedDosen,
        'ruangan_id': _selectedRuangan,
        'semester_id': _selectedSemester,
        'hari': _selectedHari,
        'jam_mulai': _jamMulaiController.text,
        'jam_selesai': _jamSelesaiController.text,
        'kuota': _kuotaController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil diupdate!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
          "Edit Jadwal",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.info),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "PILIH DATA UTAMA",
                    style: TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: "Mata Kuliah",
                    value: _selectedMatkul,
                    items: _matkulList
                        .map(
                          (mk) => DropdownMenuItem<String>(
                            value: mk.id,
                            child: Text(
                              "${mk.kodeMatkul} - ${mk.namaMatkul}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedMatkul = val),
                  ),
                  _buildDropdown(
                    label: "Dosen Pengajar",
                    value: _selectedDosen,
                    items: _dosenList
                        .map(
                          (d) => DropdownMenuItem<String>(
                            value: d.userId,
                            child: Text(
                              d.namaLengkap,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDosen = val),
                  ),
                  _buildDropdown(
                    label: "Semester",
                    value: _selectedSemester,
                    items: _semesterList
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                              s.namaSemester,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSemester = val),
                  ),
                  _buildDropdown(
                    label: "Ruangan",
                    value: _selectedRuangan,
                    items: _ruanganList
                        .map(
                          (r) => DropdownMenuItem<String>(
                            value: r.id,
                            child: Text(
                              "${r.nama} (${r.gedung ?? '-'})",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRuangan = val),
                  ),
                  const Divider(color: AppColors.divider, height: 30),
                  const Text(
                    "WAKTU & KUOTA",
                    style: TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: "Hari",
                    value: _selectedHari,
                    items: _hariList
                        .map(
                          (h) => DropdownMenuItem<String>(
                            value: h,
                            child: Text(h),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedHari = val),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInput(
                          "Jam Mulai",
                          _jamMulaiController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeInput(
                          "Jam Selesai",
                          _jamSelesaiController,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _kuotaController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Kuota Mahasiswa",
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
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isSaving ? null : _submitData,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Update Jadwal",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.surface,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v == null ? 'Silakan pilih $label' : null,
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(context, controller),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          suffixIcon: const Icon(Icons.access_time, color: AppColors.info),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}
