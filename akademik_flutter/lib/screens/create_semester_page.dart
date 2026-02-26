import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/semester_service.dart';

class CreateSemesterPage extends StatefulWidget {
  const CreateSemesterPage({super.key});

  @override
  State<CreateSemesterPage> createState() => _CreateSemesterPageState();
}

class _CreateSemesterPageState extends State<CreateSemesterPage> {
  final _formKey = GlobalKey<FormState>();
  final SemesterService _semesterService = SemesterService();
  final _namaController = TextEditingController();
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isActive = false;
  bool _isSaving = false;

  Future<void> _selectDate(BuildContext context, bool isMulai) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null)
      setState(() {
        if (isMulai)
          _tanggalMulai = picked;
        else
          _tanggalSelesai = picked;
      });
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _semesterService.createSemester({
        'nama': _namaController.text.trim(),
        'tanggal_mulai': _formatDate(_tanggalMulai),
        'tanggal_selesai': _formatDate(_tanggalSelesai),
        'is_active': _isActive,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semester berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
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
          "Tambah Semester",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: "Nama Semester (Cth: Ganjil 2024)",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.class_, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: AppColors.surface,
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: Text(
                _tanggalMulai == null
                    ? "Pilih Tanggal Mulai"
                    : _formatDate(_tanggalMulai)!,
                style: TextStyle(
                  color: _tanggalMulai == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: AppColors.surface,
              leading: const Icon(
                Icons.event_available,
                color: AppColors.primary,
              ),
              title: Text(
                _tanggalSelesai == null
                    ? "Pilih Tanggal Selesai"
                    : _formatDate(_tanggalSelesai)!,
                style: TextStyle(
                  color: _tanggalSelesai == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                "Status Aktif",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _isActive
                    ? "Semester Sedang Berjalan"
                    : "Semester Selesai / Belum Mulai",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              activeThumbColor: AppColors.primary,
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              value: _isActive,
              onChanged: (bool value) => setState(() => _isActive = value),
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
                      "Simpan Semester",
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
