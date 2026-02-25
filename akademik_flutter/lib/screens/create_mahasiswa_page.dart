import 'package:flutter/material.dart';
import '../services/mahasiswa_service.dart';

class CreateMahasiswaPage extends StatefulWidget {
  const CreateMahasiswaPage({super.key});

  @override
  State<CreateMahasiswaPage> createState() => _CreateMahasiswaPageState();
}

class _CreateMahasiswaPageState extends State<CreateMahasiswaPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _angkatanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final MahasiswaService _mahasiswaService = MahasiswaService();

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dataKirim = {
        'nama_user': _namaController.text,
        'email_user': _emailController.text,
        'password_user': _passwordController.text,
        'nim': _nimController.text,
        'jurusan': _jurusanController.text,
        'angkatan': _angkatanController
            .text, 
      };

      await _mahasiswaService.createMahasiswa(dataKirim);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mahasiswa berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nimController.dispose();
    _jurusanController.dispose();
    _angkatanController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isRequired = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber
            ? TextInputType.number
            : TextInputType.text, // Paksa keyboard angka jika isNumber true
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
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          "Tambah Mahasiswa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "INFORMASI AKUN LOGIN",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField("Nama Lengkap", _namaController, isRequired: true),
            _buildTextField("Email", _emailController, isRequired: true),
            _buildTextField(
              "Password",
              _passwordController,
              isPassword: true,
              isRequired: true,
            ),

            const Divider(color: Colors.grey, height: 30),

            const Text(
              "PROFIL MAHASISWA",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField("NIM", _nimController, isRequired: true),
            _buildTextField("Jurusan", _jurusanController, isRequired: true),
            _buildTextField(
              "Angkatan (Contoh: 2023)",
              _angkatanController,
              isRequired: true,
              isNumber: true,
            ), // Keyboard angka

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Simpan Mahasiswa",
                        style: TextStyle(
                          color: Colors.black,
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
