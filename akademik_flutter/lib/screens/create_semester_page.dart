import 'package:flutter/material.dart';
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
  bool _isActive = false; // Default: tidak aktif

  bool _isSaving = false;

  // FUNGSI UNTUK MEMUNCULKAN KALENDER
  Future<void> _selectDate(BuildContext context, bool isMulai) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.amber, onPrimary: Colors.black, surface: Color(0xFF1F2937), onSurface: Colors.white),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isMulai) _tanggalMulai = picked;
        else _tanggalSelesai = picked;
      });
    }
  }

  // UBAH FORMAT TANGGAL UNTUK LARAVEL (YYYY-MM-DD)
  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // KIRIM DATA LENGKAP KE KURIR
      await _semesterService.createSemester({
        'nama': _namaController.text.trim(),
        'tanggal_mulai': _formatDate(_tanggalMulai),
        'tanggal_selesai': _formatDate(_tanggalSelesai),
        'is_active': _isActive,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semester berhasil disimpan!'), backgroundColor: Colors.green));
      Navigator.pop(context, true); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(title: const Text("Tambah Semester", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. INPUT NAMA
            TextFormField(
              controller: _namaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama Semester (Cth: Ganjil 2024)", labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.class_, color: Colors.amber),
                filled: true, fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // 2. TANGGAL MULAI
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.calendar_today, color: Colors.amber),
              title: Text(_tanggalMulai == null ? "Pilih Tanggal Mulai" : _formatDate(_tanggalMulai)!, style: TextStyle(color: _tanggalMulai == null ? Colors.grey : Colors.white)),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),

            // 3. TANGGAL SELESAI
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.event_available, color: Colors.amber),
              title: Text(_tanggalSelesai == null ? "Pilih Tanggal Selesai" : _formatDate(_tanggalSelesai)!, style: TextStyle(color: _tanggalSelesai == null ? Colors.grey : Colors.white)),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),

            // 4. TOGGLE IS ACTIVE
            SwitchListTile(
              title: const Text("Status Aktif", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_isActive ? "Semester Sedang Berjalan" : "Semester Selesai / Belum Mulai", style: const TextStyle(color: Colors.grey)),
              activeThumbColor: Colors.amber,
              tileColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              value: _isActive,
              onChanged: (bool value) => setState(() => _isActive = value),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSaving ? null : _submitData,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("Simpan Semester", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}