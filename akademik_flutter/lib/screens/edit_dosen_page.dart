import 'package:flutter/material.dart';
import '../services/dosen_service.dart';

class EditDosenPage extends StatefulWidget {
  // WAJIB: Halaman ini meminta data awal (dosenData) saat dipanggil
  final Map<String, dynamic> dosenData;

  const EditDosenPage({super.key, required this.dosenData});

  @override
  State<EditDosenPage> createState() => _EditDosenPageState();
}

class _EditDosenPageState extends State<EditDosenPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(); // Khusus password kosong dulu
  final _nipController = TextEditingController();
  final _gelarController = TextEditingController();
  final _noHpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final DosenService _dosenService = DosenService();

  @override
  void initState() {
    super.initState();
    // LOGIKA PRE-FILLED: Saat halaman dibuka, isikan data lama ke dalam pena (Controller)
    final dosen = widget.dosenData;
    _namaController.text = dosen['user']?['name'] ?? '';
    _emailController.text = dosen['user']?['email'] ?? '';
    _nipController.text = dosen['nip'] ?? '';
    _gelarController.text = dosen['gelar'] ?? '';
    _noHpController.text = dosen['no_hp'] ?? '';
    // Password sengaja tidak diisi karena itu rahasia (di-hash di database)
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final idDosen = widget.dosenData['id'].toString();

      final dataKirim = {
        'nama_lengkap': _namaController.text,
        'email': _emailController.text,
        'password':
            _passwordController.text, // Jika kosong, di Laravel diabaikan
        'nip': _nipController.text,
        'gelar': _gelarController.text,
        'no_hp': _noHpController.text,
      };

      await _dosenService.updateDosen(idDosen, dataKirim);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Dosen berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali dengan status sukses (true)
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
          "Edit Data Dosen",
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

            // Perhatikan: Password sekarang tidak required (wajib)
            _buildTextField(
              "Password Baru",
              _passwordController,
              isPassword: true,
              hint: "Kosongkan jika tidak ingin ganti password",
            ),

            const Divider(color: Colors.grey, height: 30),

            const Text(
              "PROFIL DOSEN",
              style: TextStyle(
                color: Colors.amber,
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
                  backgroundColor: Colors.blue,
                ), // Warna biru untuk Edit
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
