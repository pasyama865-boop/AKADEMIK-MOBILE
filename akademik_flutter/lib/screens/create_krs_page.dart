import 'package:flutter/material.dart';
import '../services/krs_service.dart';
import '../services/mahasiswa_service.dart';
import '../services/jadwal_service.dart';

class CreateKrsPage extends StatefulWidget {
  const CreateKrsPage({super.key});

  @override
  State<CreateKrsPage> createState() => _CreateKrsPageState();
}

class _CreateKrsPageState extends State<CreateKrsPage> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- BAGIAN YANG DIPERBAIKI (ASYNC GAP & ARGUMEN) ---
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // 1. Panggil Service (Pastikan Service sudah menerima 2 argumen seperti langkah 1 di atas)
      await _krsService.createKrs(_selectedMahasiswa!, _selectedJadwal!);

      // 2. PENJAGA PINTU (Fix Async Gap)
      // Wajib dicek: Apakah halaman ini masih aktif setelah menunggu server?
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KRS berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // 3. PENJAGA PINTU ERROR (Fix Async Gap)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Input KRS", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedMahasiswa, // Tetap gunakan value untuk kontrol state
                    items: _mahasiswaList
                        .map(
                          (m) => DropdownMenuItem(
                            value: m['id'].toString(),
                            child: Text(
                              "${m['nim']} - ${m['user']?['name'] ?? ''}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMahasiswa = v),
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    isExpanded:
                        true, // Tambahkan ini agar teks panjang tidak error
                    decoration: InputDecoration(
                      labelText: "Pilih Mahasiswa",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => v == null ? 'Wajib pilih' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedJadwal, // Tetap gunakan value
                    isExpanded: true,
                    items: _jadwalList
                        .map(
                          (j) => DropdownMenuItem(
                            value: j['id'].toString(),
                            child: Text(
                              "${j['mata_kuliah']?['nama_matkul']} | ${j['hari']} ${j['jam_mulai']?.substring(0, 5) ?? ''}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedJadwal = v),
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Pilih Jadwal",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) => v == null ? 'Wajib pilih' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isSaving ? null : _submitData,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Simpan KRS",
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
}
