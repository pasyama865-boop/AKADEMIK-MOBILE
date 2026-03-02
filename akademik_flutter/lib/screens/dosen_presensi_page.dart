import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DosenPresensiPage extends StatefulWidget {
  final String jadwalId;
  final String namaMatkul;

  const DosenPresensiPage({
    super.key,
    required this.jadwalId,
    required this.namaMatkul,
  });

  @override
  State<DosenPresensiPage> createState() => _DosenPresensiPageState();
}

class _DosenPresensiPageState extends State<DosenPresensiPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _mahasiswaList = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  Future<void> _loadDummyData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _mahasiswaList = [
          {'id': '1', 'nim': '20230001', 'nama': 'Budi Santoso', 'hadir': true},
          {'id': '2', 'nim': '20230002', 'nama': 'Siti Aminah', 'hadir': true},
          {'id': '3', 'nim': '20230003', 'nama': 'Andi Wijaya', 'hadir': false},
          {'id': '4', 'nim': '20230004', 'nama': 'Rina Marlina', 'hadir': true},
          {
            'id': '5',
            'nim': '20230005',
            'nama': 'Fajar Gunawan',
            'hadir': false,
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _simpanPresensi() {
    final hadirCount = _mahasiswaList.where((m) => m['hadir'] == true).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Berhasil menyimpan presensi ($hadirCount hadir, ${_mahasiswaList.length - hadirCount} tidak hadir)",
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor =>
      _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get _borderColor =>
      _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get _textPrimaryColor =>
      _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _textSecondaryColor =>
      _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Presensi Kelas",
              style: TextStyle(
                color: _textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.namaMatkul,
              style: TextStyle(
                color: _textSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: _surfaceColor,
        iconTheme: IconThemeData(color: _textPrimaryColor),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _simpanPresensi,
            child: const Text(
              "Simpan",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _borderColor, height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _mahasiswaList.length,
              itemBuilder: (context, index) {
                final mhs = _mahasiswaList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: mhs['hadir']
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      child: Text(
                        mhs['nama'].substring(0, 1),
                        style: TextStyle(
                          color: mhs['hadir']
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      mhs['nama'],
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      mhs['nim'],
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: mhs['hadir'],
                      activeThumbColor: AppColors.success,
                      onChanged: (val) {
                        setState(() {
                          mhs['hadir'] = val;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
