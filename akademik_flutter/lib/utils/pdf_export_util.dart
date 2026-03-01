import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/krs.dart';

/// Helper yang menangani pembuatan dan pencetakan file PDF KHS / KRS.
class PdfExportUtil {
  /// Membuka dialog pemrosesan untuk share/print PDF KHS (Transkrip Sementara).
  static Future<void> generateAndPrintKhsPdf(
    String mahasiswaNama,
    List<Krs> krsList,
    int totalSks,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'KARTU HASIL STUDI (KHS) SEMENTARA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Nama Mahasiswa : $mahasiswaNama',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Total SKS Diambil: $totalSks SKS',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Mata Kuliah', 'SKS', 'Dosen', 'Jadwal', 'Status'],
                data: krsList.map((krs) {
                  return [
                    krs.namaMatkul,
                    krs.sks.toString(),
                    krs.namaDosen,
                    '${krs.hari}, ${krs.jamFormatted}',
                    krs.status,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Disetujui oleh,'),
                    pw.SizedBox(height: 48),
                    pw.Text('(Dosen Wali)'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Transkrip_KHS_${mahasiswaNama.replaceAll(' ', '_')}.pdf',
    );
  }
}
