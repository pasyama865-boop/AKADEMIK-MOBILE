import 'package:flutter/material.dart';
import '../services/user_service.dart';

class CreateAdminPage extends StatefulWidget {
  const CreateAdminPage({super.key});

  @override
  State<CreateAdminPage> createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends State<CreateAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isSaving = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _userService.createUser({
        'name': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': 'admin',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin berhasil ditambahkan!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text("Tambah Admin", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),

            _buildTextField("Nama Lengkap", _namaController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField("Email Valid", _emailController, Icons.email, isEmail: true),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              obscureText: true, 
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password Akun", labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                filled: true, fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSaving ? null : _submitData,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("Simpan Admin", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true, fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
    );
  }
}