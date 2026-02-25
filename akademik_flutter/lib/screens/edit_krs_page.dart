import 'package:flutter/material.dart';
import '../services/krs_service.dart';
import '../services/mahasiswa_service.dart';
import '../services/jadwal_service.dart';

class EditKrsPage extends StatefulWidget {
  final Map<String, dynamic> krsData; // Wajib menerima data lama dari halaman sebelumnya

  const EditKrsPage({super.key, required this.krsData});

  @override
  State<EditKrsPage> createState() => _EditKrsPageState();
}

class _EditKrsPageState extends State<EditKrsPage> {
  final _formKey = GlobalKey<FormState>();
  final KrsService _krsService = KrsService();

  String? _selectedMahasiswa;
  String? _selectedJadwal;

  List<dynamic> _mahasiswaList = [];
  List<dynamic> _jadwalList = [];
  
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Tarik ID lama untuk dimunculkan di Dropdown
    _selectedMahasiswa = widget.krsData['mahasiswa_id']?.toString();
    _selectedJadwal = widget.krsData['jadwal_id']?.toString();
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        MahasiswaService().getMahasiswaList(),
        JadwalService().getJadwal(),
      ]);
      setState(() {
        _mahasiswaList = results[0];
        _jadwalList = results[1];
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final idKrs = widget.krsData['id'].toString();
      
      // Kirim data ke kurir
      await _krsService.updateKrs(idKrs, _selectedMahasiswa!, _selectedJadwal!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KRS berhasil diupdate!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text("Edit KRS", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue)) // Loading biru untuk Edit
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedMahasiswa,
                  items: _mahasiswaList.map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text("${m['nim']} - ${m['user']?['name'] ?? ''}", overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _selectedMahasiswa = v),
                  dropdownColor: const Color(0xFF1F2937), style: const TextStyle(color: Colors.white), isExpanded: true,
                  decoration: InputDecoration(labelText: "Pilih Mahasiswa", labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1F2937), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  validator: (v) => v == null ? 'Wajib pilih' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedJadwal,
                  isExpanded: true,
                  items: _jadwalList.map((j) => DropdownMenuItem(value: j['id'].toString(), child: Text("${j['mata_kuliah']?['nama_matkul']} | ${j['hari']} ${j['jam_mulai']?.substring(0,5) ?? ''}", overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _selectedJadwal = v),
                  dropdownColor: const Color(0xFF1F2937), style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: "Pilih Jadwal", labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1F2937), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  validator: (v) => v == null ? 'Wajib pilih' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
                  onPressed: _isSaving ? null : _submitData,
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Update KRS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }
}