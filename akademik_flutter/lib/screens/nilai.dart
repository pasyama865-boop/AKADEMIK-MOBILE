import 'package:flutter/material.dart';
import '../services/krs_service.dart';

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  final KrsService _krsService = KrsService();
  late Future<List<dynamic>> _krsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Fungsi untuk memuat ulang data
  void _refreshData() {
    setState(() {
      _krsFuture = _krsService.getKrsList();
    });
  }

  // Logika Hapus Data
  Future<void> _handleDelete(String? id, String namaMatkul) async {
    // Validasi ID
    if (id == null) {
      _showSnackBar("Error: ID Data tidak ditemukan", isError: true);
      return;
    }

    // Dialog Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Mata Kuliah"),
        content: Text("Yakin ingin membatalkan $namaMatkul?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Proses Hapus ke Server
    try {
      await _krsService.deleteKrs(id);
      
      if (mounted) {
        _showSnackBar("Mata kuliah berhasil dihapus!");
        // Refresh otomatis
        _refreshData(); 
      }
    } catch (e) {
      debugPrint("ERROR DELETE: $e");
      if (mounted) {
        _showSnackBar("Gagal: ${e.toString()}", isError: true);
      }
    }
  }

  // Helper untuk menampilkan pesan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Nilai & KRS"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _krsFuture,
        builder: (context, snapshot) {
          // STATE 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Terjadi Kesalahan:\n${snapshot.error}", textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          }

          // Data Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada mata kuliah yang diambil.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          //  Ada Data
          final krsList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: krsList.length,
            itemBuilder: (context, index) {
              return _buildKrsCard(krsList[index]);
            },
          );
        },
      ),
    );
  }

  // Kartu Item KRS
  Widget _buildKrsCard(dynamic krsData) {
    final jadwal = krsData['jadwal'] ?? {};
    final matkulData = jadwal['matakuliah'] ?? {};

    final String namaMatkul = matkulData['nama_matkul'] ?? 'Tanpa Nama';
    final String kodeMatkul = matkulData['kode_matkul'] ?? '-';
    final int sks = matkulData['sks'] ?? 0;
    final dynamic nilai = krsData['nilai_akhir'] ?? 'Belum Dinilai';
    final String? idKrs = krsData['id']?.toString();

    final bool isNilaiMasuk = nilai != 'Belum Dinilai';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getWarnaNilai(nilai),
          child: Text(
            isNilaiMasuk ? nilai.toString() : '-',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Text(
          namaMatkul,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("$kodeMatkul • $sks SKS"),
        ),
        // Tombol Sampah hanya muncul jika nilai belum keluar
        trailing: !isNilaiMasuk
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "Batalkan Mata Kuliah",
                onPressed: () => _handleDelete(idKrs, namaMatkul),
              )
            : null,
      ),
    );
  }

  // Helper Warna Nilai
  Color _getWarnaNilai(dynamic nilai) {
    switch (nilai) {
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.red;
      case 'E': return Colors.black;
      default: return Colors.grey; 
    }
  }
}