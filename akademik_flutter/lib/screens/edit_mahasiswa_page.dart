import 'package:flutter/material.dart';
import '../services/mahasiswa_service.dart';

class EditMahasiswaPage extends StatefulWidget {
  final Map<String, dynamic> mahasiswaData;

  const EditMahasiswaPage({super.key, required this.mahasiswaData});

  @override
  State<EditMahasiswaPage> createState() => _EditMahasiswaPageState();
}

class _EditMahasiswaPageState extends State<EditMahasiswaPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _angkatanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final MahasiswaService _mahasiswaService = MahasiswaService();

  @override
  void initState() {
    super.initState();
    final mhs = widget.mahasiswaData;
    _namaController.text = mhs['user']?['name'] ?? '';
    _emailController.text = mhs['user']?['email'] ?? '';
    _nimController.text = mhs['nim'] ?? '';
    _jurusanController.text = mhs['jurusan'] ?? '';
    _angkatanController.text = mhs['angkatan']?.toString() ?? '';
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final idMhs = widget.mahasiswaData['id'].toString();

      final dataKirim = {
        'nama_user': _namaController.text,
        'email_user': _emailController.text,
        'password_user': _passwordController.text,
        'nim': _nimController.text,
        'jurusan': _jurusanController.text,
        'angkatan': _angkatanController.text,
      };

      await _mahasiswaService.updateMahasiswa(idMhs, dataKirim);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Mahasiswa berhasil diubah!'),
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
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
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
          "Edit Data Mahasiswa",
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
              "Password Baru",
              _passwordController,
              isPassword: true,
              hint: "Kosongkan jika tidak ingin ganti password",
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
              "Angkatan",
              _angkatanController,
              isRequired: true,
              isNumber: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update Mahasiswa",
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
