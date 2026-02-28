import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/jadwal.dart';
import '../models/krs.dart';
import '../services/mahasiswa_krs_service.dart';

/// Halaman KRS Mahasiswa.
class MahasiswaKrsPage extends StatefulWidget {
  const MahasiswaKrsPage({super.key});

  @override
  State<MahasiswaKrsPage> createState() => _MahasiswaKrsPageState();
}

class _MahasiswaKrsPageState extends State<MahasiswaKrsPage>
    with SingleTickerProviderStateMixin {
  final MahasiswaKrsService _service = MahasiswaKrsService();
  late TabController _tabController;

  // Data
  List<Jadwal> _jadwalList = [];
  List<Krs> _krsList = [];
  int _totalSks = 0;
  final Set<String> _selectedJadwalIds = {};
  Set<String> _sudahDiambilJadwalIds = {};

  // State
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _service.getJadwalTersedia(),
        _service.getMyKrs(),
      ]);

      final jadwalList = results[0] as List<Jadwal>;
      final krsData = results[1] as Map<String, dynamic>;

      setState(() {
        _jadwalList = jadwalList;
        _krsList = krsData['krs'] as List<Krs>;
        _totalSks = krsData['totalSks'] as int;
        _sudahDiambilJadwalIds = _krsList.map((k) => k.jadwalId).toSet();
        _selectedJadwalIds.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _ambilJadwalTerpilih() async {
    if (_selectedJadwalIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu jadwal terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    int berhasil = 0;
    String? lastError;

    for (final jadwalId in _selectedJadwalIds) {
      try {
        await _service.ambilJadwal(jadwalId);
        berhasil++;
      } catch (e) {
        lastError = e.toString();
      }
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (berhasil > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$berhasil mata kuliah berhasil diambil!'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
      // Switch ke tab KRS Saya
      _tabController.animateTo(1);
    }

    if (lastError != null && berhasil < _selectedJadwalIds.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sebagian gagal: $lastError'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _batalkanKrs(Krs krs) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Mata Kuliah?',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Kamu yakin ingin membatalkan\n"${krs.namaMatkul}"?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Tidak',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.batalkanKrs(krs.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${krs.namaMatkul} berhasil dibatalkan'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  int get _selectedSks {
    int sks = 0;
    for (final id in _selectedJadwalIds) {
      final jadwal = _jadwalList.firstWhere(
        (j) => j.id == id,
        orElse: () => _jadwalList.first,
      );
      sks += jadwal.sks;
    }
    return sks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kartu Rencana Studi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Ambil MK'),
            Tab(icon: Icon(Icons.assignment), text: 'KRS Saya'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
          ? _buildErrorWidget()
          : Column(
              children: [
                // SKS Summary Bar
                _buildSksSummary(),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildTabAmbilMK(), _buildTabKrsSaya()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSksSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.surface],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total SKS Diambil',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_totalSks',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' / 24 SKS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedJadwalIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+$_selectedSks SKS',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: Ambil Mata Kuliah
  // ============================================================

  Widget _buildTabAmbilMK() {
    // Filter: hanya jadwal yang belum diambil
    final tersedia = _jadwalList
        .where((j) => !_sudahDiambilJadwalIds.contains(j.id))
        .toList();

    return Column(
      children: [
        // List Jadwal
        Expanded(
          child: tersedia.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 64,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Semua jadwal sudah kamu ambil!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tersedia.length,
                    itemBuilder: (context, index) {
                      return _buildJadwalCard(tersedia[index]);
                    },
                  ),
                ),
        ),
        // Bottom action bar
        if (_selectedJadwalIds.isNotEmpty) _buildBottomActionBar(),
      ],
    );
  }

  Widget _buildJadwalCard(Jadwal jadwal) {
    final isSelected = _selectedJadwalIds.contains(jadwal.id);
    final isFull = jadwal.isFull;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isFull
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedJadwalIds.remove(jadwal.id);
                    } else {
                      _selectedJadwalIds.add(jadwal.id);
                    }
                  });
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Checkbox + Mata Kuliah Name + SKS Badge
                Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFull
                            ? Colors.grey[800]
                            : isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isFull
                              ? Colors.grey[600]!
                              : isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 18,
                            )
                          : isFull
                          ? const Icon(
                              Icons.block,
                              color: Colors.grey,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Nama Matkul
                    Expanded(
                      child: Text(
                        jadwal.namaMatkul,
                        style: TextStyle(
                          color: isFull
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // SKS Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${jadwal.sks} SKS',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Detail Row
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      // Hari & Waktu
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorForDay(
                                jadwal.hari,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              jadwal.hari,
                              style: TextStyle(
                                color: _getColorForDay(jadwal.hari),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jadwal.jamFormatted,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Dosen & Ruangan & Kuota
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              jadwal.namaDosen,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.room,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jadwal.namaRuangan,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Kuota bar
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${jadwal.pesertaCount}/${jadwal.kuota}',
                            style: TextStyle(
                              color: isFull
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isFull ? FontWeight.bold : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: jadwal.kuota > 0
                                    ? jadwal.pesertaCount / jadwal.kuota
                                    : 0,
                                backgroundColor: AppColors.textSecondary
                                    .withValues(alpha: 0.2),
                                color: isFull
                                    ? AppColors.error
                                    : AppColors.success,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          if (isFull)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PENUH',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedJadwalIds.length} mata kuliah dipilih',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total: +$_selectedSks SKS',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _ambilJadwalTerpilih,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'Ambil KRS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 2: KRS Saya (Jadwal yang sudah diambil)
  // ============================================================

  Widget _buildTabKrsSaya() {
    if (_krsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: AppColors.textSecondary,
              size: 64,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada mata kuliah diambil',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Pilih jadwal di tab "Ambil MK"',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Group KRS by hari
    final Map<String, List<Krs>> grouped = {};
    final dayOrder = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    for (final krs in _krsList) {
      grouped.putIfAbsent(krs.hari, () => []).add(krs);
    }

    // Sort groups by day order
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        final ia = dayOrder.indexOf(a);
        final ib = dayOrder.indexOf(b);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final day in sortedDays) ...[
            // Day Header
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorForDay(day).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: _getColorForDay(day),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${grouped[day]!.length} mata kuliah',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // KRS Cards for this day
            for (final krs in grouped[day]!) _buildKrsCard(krs),
          ],
        ],
      ),
    );
  }

  Widget _buildKrsCard(Krs krs) {
    final jamDisplay = krs.jamMulai.length >= 5
        ? krs.jamMulai.substring(0, 5)
        : krs.jamMulai;
    final jamEnd = krs.jamSelesai.length >= 5
        ? krs.jamSelesai.substring(0, 5)
        : krs.jamSelesai;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Nama Matkul & SKS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        krs.namaMatkul,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${krs.sks} SKS • ${krs.namaDosen}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: () => _batalkanKrs(krs),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'Batalkan',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Time & Room
            Row(
              children: [
                const SizedBox(width: 4),
                const Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$jamDisplay - $jamEnd',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.room,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  krs.namaRuangan,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Warna per hari
  Color _getColorForDay(String hari) {
    switch (hari.toLowerCase()) {
      case 'senin':
        return Colors.blue;
      case 'selasa':
        return Colors.green;
      case 'rabu':
        return Colors.orange;
      case 'kamis':
        return Colors.purple;
      case 'jumat':
        return Colors.teal;
      case 'sabtu':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
