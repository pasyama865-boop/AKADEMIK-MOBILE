import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/ruangan_service.dart';

class CreateRuanganPage extends StatefulWidget {
  const CreateRuanganPage({super.key});

  @override
  State<CreateRuanganPage> createState() => _CreateRuanganPageState();
}

class _CreateRuanganPageState extends State<CreateRuanganPage> {
  final _formKey = GlobalKey<FormState>();
  final RuanganService _ruanganService = RuanganService();
  final _namaController = TextEditingController();
  final _gedungController = TextEditingController();
  final _kapasitasController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _ruanganService.createRuangan({
        'nama': _namaController.text,
        'gedung': _gedungController.text,
        'kapasitas': int.parse(_kapasitasController.text),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ruangan berhasil disimpan!'),
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
          "Tambah Ruangan",
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
            _buildTextField(
              "Nama Ruangan",
              _namaController,
              Icons.meeting_room,
            ),
            const SizedBox(height: 16),
            _buildTextField("Nama Gedung", _gedungController, Icons.business),
            const SizedBox(height: 16),
            _buildTextField(
              "Kapasitas (Orang)",
              _kapasitasController,
              Icons.people,
              isNumber: true,
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
                      "Simpan Ruangan",
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
    );
  }
}
