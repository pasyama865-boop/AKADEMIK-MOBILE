import 'package:flutter/material.dart';
import '../services/user_service.dart';

class EditAdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditAdminPage({super.key, required this.userData});

  @override
  State<EditAdminPage> createState() => _EditAdminPageState();
}

class _EditAdminPageState extends State<EditAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController(); 

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final id = widget.userData['id'].toString();
      
      Map<String, dynamic> dataKirim = {
        'name': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'admin', // Kunci mutlak
      };

      if (_passwordController.text.isNotEmpty) {
        dataKirim['password'] = _passwordController.text;
      }

      await _userService.updateUser(id, dataKirim);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin berhasil diupdate!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text("Edit Admin", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField("Nama Lengkap", _namaController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, Icons.email, isEmail: true),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password Baru (Kosongkan jika tidak diganti)", labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                filled: true, fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSaving ? null : _submitData,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true, fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
    );
  }
}