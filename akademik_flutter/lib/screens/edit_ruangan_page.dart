import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // --- PERBAIKAN: Untuk Filter Input (Formatters) ---
import '../services/ruangan_service.dart';

class EditRuanganPage extends StatefulWidget {
  final Map<String, dynamic> ruanganData; // Data lama

  const EditRuanganPage({super.key, required this.ruanganData});

  @override
  State<EditRuanganPage> createState() => _EditRuanganPageState();
}

class _EditRuanganPageState extends State<EditRuanganPage> {
  final _formKey = GlobalKey<FormState>();
  final RuanganService _ruanganService = RuanganService();

  late TextEditingController _namaController;
  late TextEditingController _gedungController;
  late TextEditingController _kapasitasController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.ruanganData['nama']);
    _gedungController = TextEditingController(text: widget.ruanganData['gedung'] ?? '');
    _kapasitasController = TextEditingController(text: widget.ruanganData['kapasitas'].toString());
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    // --- PERBAIKAN 1: PENGAMANAN ANGKA KAPASITAS ---
    final kapasitasAngka = int.tryParse(_kapasitasController.text.trim());
    if (kapasitasAngka == null || kapasitasAngka <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kapasitas harus angka > 0!'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // --- PERBAIKAN 2: AMBIL ID RUANGAN ---
      final idRuangan = widget.ruanganData['id'].toString();

      // --- PERBAIKAN 3: GUNAKAN UPDATE, BUKAN CREATE ---
      await _ruanganService.updateRuangan(idRuangan, {
        'nama': _namaController.text.trim(),
        'gedung': _gedungController.text.trim(),
        'kapasitas': kapasitasAngka, 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruangan berhasil diupdate!'), backgroundColor: Colors.green));
      
      // Sinyal sukses (true) agar halaman depan merefresh data
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
      appBar: AppBar(title: const Text("Edit Ruangan", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField("Nama Ruangan", _namaController, Icons.meeting_room),
            const SizedBox(height: 16),
            _buildTextField("Nama Gedung", _gedungController, Icons.business),
            const SizedBox(height: 16),
            _buildTextField("Kapasitas", _kapasitasController, Icons.people, isNumber: true),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSaving ? null : _submitData,
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Update Ruangan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN 4: TAMBAH FILTER KEYBOARD UNTUK ANGKA ---
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [], // Paksa hanya angka
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blue), // Ikon biru untuk edit
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null,
    );
  }
}