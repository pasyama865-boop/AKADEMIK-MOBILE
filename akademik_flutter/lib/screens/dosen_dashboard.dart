import 'package:flutter/material.dart';

class DosenDashboard extends StatelessWidget {
  const DosenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.co_present, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Selamat Datang, Dosen!', style: TextStyle(fontSize: 24)),
            // Nanti di sini kita tambahkan list jadwal mengajar
          ],
        ),
      ),
    );
  }
}