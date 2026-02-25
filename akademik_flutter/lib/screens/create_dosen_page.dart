import 'package:flutter/material.dart';
import '../services/dosen_service.dart';

class CreateDosenPage extends StatefulWidget {
  const CreateDosenPage({super.key});

  @override
  State<CreateDosenPage> createState() => _CreateDosenPageState();
}

class _CreateDosenPageState extends State<CreateDosenPage> {
  // 1. SIAPKAN PENA PENCATAT (Controller)
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nipController = TextEditingController();
  final _gelarController = TextEditingController();
  final _noHpController = TextEditingController();

  // 2. SIAPKAN KUNCI FORMULIR (Untuk validasi input kosong)
  final _formKey = GlobalKey<FormState>();
  
  // 3. SIAPKAN STATUS LOADING
  bool _isLoading = false;

  final DosenService _dosenService = DosenService();

  // FUNGSI EKSEKUSI SIMPAN
  Future<void> _submitData() async {
    // Cek apakah ada kolom wajib yang masih kosong
    if (!_formKey.currentState!.validate()) return;

    // Kunci tombol agar tidak diklik berkali-kali
    setState(() => _isLoading = true);

    try {
      // Bungkus data ke dalam kardus (Map) sesuai permintaan Laravel
      final dataKirim = {
        'nama_lengkap': _namaController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'nip': _nipController.text,
        'gelar': _gelarController.text,
        'no_hp': _noHpController.text,
      };

      // Suruh kurir mengirim paketnya
      await _dosenService.createDosen(dataKirim);

      // JIKA BERHASIL: Tampilkan pesan sukses & tutup halaman ini
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosen berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Buka kunci tombol
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // WAJIB: Buang pena pencatat jika halaman ditutup agar memori HP tidak penuh (Memory Leak)
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    _gelarController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  // DESAIN KOTAK INPUT (Biar kodenya tidak panjang dan berulang)
  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        // Validasi jika required (wajib diisi)
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
        title: const Text("Tambah Dosen Baru", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey, // Pasang kunci di sini
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("INFORMASI AKUN LOGIN", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField("Nama Lengkap", _namaController, isRequired: true),
            _buildTextField("Email", _emailController, isRequired: true),
            _buildTextField("Password", _passwordController, isPassword: true, isRequired: true),
            
            const Divider(color: Colors.grey, height: 30),
            
            const Text("PROFIL DOSEN", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField("NIP", _nipController, isRequired: true),
            _buildTextField("Gelar (Opsional)", _gelarController),
            _buildTextField("No HP (Opsional)", _noHpController),
            
            const SizedBox(height: 20),
            
            // TOMBOL SIMPAN
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black) 
                    : const Text("Simpan Dosen", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}