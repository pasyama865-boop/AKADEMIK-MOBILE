import 'package:flutter/material.dart';
import '../services/jadwal_service.dart';
import '../services/matakuliah_service.dart';
import '../services/dosen_service.dart';
import '../services/ruangan_service.dart';
import '../services/semester_service.dart';

class EditJadwalPage extends StatefulWidget {
  // WAJIB: Menerima data jadwal yang mau diedit dari halaman sebelumnya
  final Map<String, dynamic> jadwalData;

  const EditJadwalPage({super.key, required this.jadwalData});

  @override
  State<EditJadwalPage> createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final JadwalService _jadwalService = JadwalService();

  final _kuotaController = TextEditingController();
  final _jamMulaiController = TextEditingController();
  final _jamSelesaiController = TextEditingController();

  String? _selectedMatkul;
  String? _selectedDosen;
  String? _selectedRuangan;
  String? _selectedSemester;
  String? _selectedHari;

  List<dynamic> _matkulList = [];
  List<dynamic> _dosenList = [];
  List<dynamic> _ruanganList = [];
  List<dynamic> _semesterList = [];
  
  bool _isLoadingData = true; 
  bool _isSaving = false;     

  final List<String> _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void initState() {
    super.initState();
    _setInitialData(); // Masukkan data lama ke variabel
    _loadDropdownData(); // Ambil daftar pilihan dari API
  }

  // FUNGSI UNTUK MENGISI DATA LAMA (PRE-FILLED)
  void _setInitialData() {
    final jadwal = widget.jadwalData;
    
    _selectedMatkul = jadwal['mata_kuliah_id']?.toString();
    _selectedDosen = jadwal['dosen_id']?.toString();
    _selectedRuangan = jadwal['ruangan_id']?.toString();
    _selectedSemester = jadwal['semester_id']?.toString();
    _selectedHari = jadwal['hari'];
    _kuotaController.text = jadwal['kuota']?.toString() ?? '';

    final jamMulaiMentah = jadwal['jam_mulai']?.toString() ?? '';
    _jamMulaiController.text = jamMulaiMentah.length >= 5 ? jamMulaiMentah.substring(0, 5) : jamMulaiMentah;

    final jamSelesaiMentah = jadwal['jam_selesai']?.toString() ?? '';
    _jamSelesaiController.text = jamSelesaiMentah.length >= 5 ? jamSelesaiMentah.substring(0, 5) : jamSelesaiMentah;
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        MatakuliahService().getMataKuliahList(),
        DosenService().getDosenList(),
        RuanganService().getRuanganList(),
        SemesterService().getSemesterList(),
      ]);

      setState(() {
        _matkulList = results[0];
        _dosenList = results[1];
        _ruanganList = results[2];
        _semesterList = results[3];
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data pilihan'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.amber, onPrimary: Colors.black, surface: Color(0xFF1F2937), onSurface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final jam = picked.hour.toString().padLeft(2, '0');
        final menit = picked.minute.toString().padLeft(2, '0');
        controller.text = "$jam:$menit";
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final idJadwal = widget.jadwalData['id'].toString(); // Ambil ID Jadwal yang mau diedit
      
      await _jadwalService.updateJadwal(idJadwal, {
        'mata_kuliah_id': _selectedMatkul,
        'dosen_id': _selectedDosen,
        'ruangan_id': _selectedRuangan,
        'semester_id': _selectedSemester,
        'hari': _selectedHari,
        'jam_mulai': _jamMulaiController.text,
        'jam_selesai': _jamSelesaiController.text,
        'kuota': _kuotaController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(title: const Text("Edit Jadwal", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1F2937)),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue)) // Warna loading biru untuk edit
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("PILIH DATA UTAMA", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                _buildDropdown(
                  label: "Mata Kuliah",
                  value: _selectedMatkul,
                  items: _matkulList.map((item) => DropdownMenuItem<String>(
                    value: item['id'].toString(), 
                    child: Text("${item['kode_matkul']} - ${item['nama_matkul']}", overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedMatkul = val),
                ),

                _buildDropdown(
                  label: "Dosen Pengajar",
                  value: _selectedDosen,
                  items: _dosenList.map((item) => DropdownMenuItem<String>(
                    value: item['user_id'].toString(), 
                    child: Text(item['user']?['name'] ?? 'Tanpa Nama', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedDosen = val),
                ),

                _buildDropdown(
                  label: "Semester",
                  value: _selectedSemester,
                  items: _semesterList.map((item) => DropdownMenuItem<String>(
                    value: item['id'].toString(), 
                    child: Text(item['nama'] ?? 'Tanpa Nama', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedSemester = val),
                ),

                _buildDropdown(
                  label: "Ruangan",
                  value: _selectedRuangan,
                  items: _ruanganList.map((item) => DropdownMenuItem<String>(
                    value: item['id'].toString(), 
                    child: Text("${item['nama']} (${item['gedung'] ?? '-'})", overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedRuangan = val),
                ),

                const Divider(color: Colors.grey, height: 30),
                const Text("WAKTU & KUOTA", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                _buildDropdown(
                  label: "Hari",
                  value: _selectedHari,
                  items: _hariList.map((hari) => DropdownMenuItem<String>(value: hari, child: Text(hari))).toList(),
                  onChanged: (val) => setState(() => _selectedHari = val),
                ),

                Row(
                  children: [
                    Expanded(child: _buildTimeInput("Jam Mulai", _jamMulaiController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeInput("Jam Selesai", _jamSelesaiController)),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _kuotaController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Kuota Mahasiswa", labelStyle: const TextStyle(color: Colors.grey),
                      filled: true, fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),

                const SizedBox(height: 20),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
                  onPressed: _isSaving ? null : _submitData,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Update Jadwal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1F2937),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.grey),
          filled: true, fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        validator: (v) => v == null ? 'Silakan pilih $label' : null,
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(context, controller),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.grey),
          filled: true, fillColor: const Color(0xFF1F2937),
          suffixIcon: const Icon(Icons.access_time, color: Colors.amber), // Biarkan icon tetap amber agar selaras dengan desain
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}