import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon atau Logo
            const Icon(
              Icons.calendar_today,
              size: 80,
              color: Color(0xFF7494EC),
            ),
            const SizedBox(height: 30),

            // Judul
            Text(
              'Pengingat Jadwal Kuliah',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7494EC),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Kelola jadwal kuliah dan tugas Anda dengan mudah',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),

            // Tombol Masuk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
