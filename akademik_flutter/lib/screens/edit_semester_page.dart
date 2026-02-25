import 'package:flutter/material.dart';
import '../services/semester_service.dart';

class EditSemesterPage extends StatefulWidget {
  final Map<String, dynamic> semesterData;
  const EditSemesterPage({super.key, required this.semesterData});

  @override
  State<EditSemesterPage> createState() => _EditSemesterPageState();
}

class _EditSemesterPageState extends State<EditSemesterPage> {
  final _formKey = GlobalKey<FormState>();
  final SemesterService _semesterService = SemesterService();
  
  late TextEditingController _namaController;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isActive = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Tarik data lama ke dalam variabel (Pre-filled)
    _namaController = TextEditingController(text: widget.semesterData['nama']);
    _tanggalMulai = DateTime.tryParse(widget.semesterData['tanggal_mulai'] ?? '');
    _tanggalSelesai = DateTime.tryParse(widget.semesterData['tanggal_selesai'] ?? '');
    
    // Konversi nilai database (0/1 atau true/false) ke boolean Flutter
    final activeData = widget.semesterData['is_active'];
    _isActive = (activeData == 1 || activeData == true || activeData == '1');
  }

  Future<void> _selectDate(BuildContext context, bool isMulai) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isMulai ? _tanggalMulai : _tanggalSelesai) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.blue, onPrimary: Colors.white, surface: Color(0xFF1F2937), onSurface: Colors.white)),
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

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final id = widget.semesterData['id'].toString();
      await _semesterService.updateSemester(id, {
        'nama': _namaController.text.trim(),
        'tanggal_mulai': _formatDate(_tanggalMulai),
        'tanggal_selesai': _formatDate(_tanggalSelesai),
        'is_active': _isActive,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semester berhasil diupdate!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text("Edit Semester", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama Semester", labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.edit, color: Colors.blue),
                filled: true, fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(_tanggalMulai == null ? "Pilih Tanggal Mulai" : _formatDate(_tanggalMulai)!, style: TextStyle(color: _tanggalMulai == null ? Colors.grey : Colors.white)),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),

            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), tileColor: const Color(0xFF1F2937),
              leading: const Icon(Icons.event_available, color: Colors.blue),
              title: Text(_tanggalSelesai == null ? "Pilih Tanggal Selesai" : _formatDate(_tanggalSelesai)!, style: TextStyle(color: _tanggalSelesai == null ? Colors.grey : Colors.white)),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text("Status Aktif", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_isActive ? "Semester Sedang Berjalan" : "Semester Selesai / Belum Mulai", style: const TextStyle(color: Colors.grey)),
              activeThumbColor: Colors.blue, tileColor: const Color(0xFF1F2937), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              value: _isActive,
              onChanged: (bool value) => setState(() => _isActive = value),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSaving ? null : _submitData,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Semester", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}