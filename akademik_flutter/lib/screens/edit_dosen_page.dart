import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/dosen_service.dart';

class EditDosenPage extends StatefulWidget {
  final Map<String, dynamic> dosenData;
  const EditDosenPage({super.key, required this.dosenData});

  @override
  State<EditDosenPage> createState() => _EditDosenPageState();
}

class _EditDosenPageState extends State<EditDosenPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nipController = TextEditingController();
  final _gelarController = TextEditingController();
  final _noHpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final DosenService _dosenService = DosenService();

  @override
  void initState() {
    super.initState();
    final dosen = widget.dosenData;
    _namaController.text = dosen['user']?['name'] ?? '';
    _emailController.text = dosen['user']?['email'] ?? '';
    _nipController.text = dosen['nip'] ?? '';
    _gelarController.text = dosen['gelar'] ?? '';
    _noHpController.text = dosen['no_hp'] ?? '';
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _dosenService.updateDosen(widget.dosenData['id'].toString(), {
        'nama_lengkap': _namaController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'nip': _nipController.text,
        'gelar': _gelarController.text,
        'no_hp': _noHpController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Dosen berhasil diubah!'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    _gelarController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isRequired = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty))
            return '$label wajib diisi';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Edit Data Dosen",
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
            const Text(
              "INFORMASI AKUN LOGIN",
              style: TextStyle(
                color: AppColors.info,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField("Nama Lengkap", _namaController, isRequired: true),
            _buildTextField("Email", _emailController, isRequired: true),
            _buildTextField(
              "Password Baru",
              _passwordController,
              isPassword: true,
              hint: "Kosongkan jika tidak ingin ganti password",
            ),
            const Divider(color: AppColors.divider, height: 30),
            const Text(
              "PROFIL DOSEN",
              style: TextStyle(
                color: AppColors.info,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField("NIP", _nipController, isRequired: true),
            _buildTextField("Gelar (Opsional)", _gelarController),
            _buildTextField("No HP (Opsional)", _noHpController),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                ),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update Dosen",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
