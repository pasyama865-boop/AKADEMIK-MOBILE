import 'package:flutter/material.dart';
import '../services/matakuliah_service.dart';

class EditMataKuliahPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditMataKuliahPage({super.key, required this.data});

  @override
  State<EditMataKuliahPage> createState() => _EditMataKuliahPageState();
}

class _EditMataKuliahPageState extends State<EditMataKuliahPage> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _sksController = TextEditingController();
  final _semesterController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final MatakuliahService _service = MatakuliahService();

  @override
  void initState() {
    super.initState();
    _kodeController.text = widget.data['kode_matkul'] ?? '';
    _namaController.text = widget.data['nama_matkul'] ?? '';
    _sksController.text = widget.data['sks']?.toString() ?? '';
    _semesterController.text = widget.data['semester_paket']?.toString() ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.updateMataKuliah(widget.data['id'].toString(), {
        'kode_matkul': _kodeController.text,
        'nama_matkul': _namaController.text,
        'sks': _sksController.text,
        'semester_paket': _semesterController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Edit Matkul", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInput("Kode Matkul", _kodeController),
            _buildInput("Nama Mata Kuliah", _namaController),
            _buildInput("SKS", _sksController, isNumber: true),
            _buildInput("Semester Paket", _semesterController, isNumber: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      "Update",
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
}
