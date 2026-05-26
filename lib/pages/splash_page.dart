import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:litera2/pages/main_page.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D5A41),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.auto_stories, size: 100, color: Colors.white70),
            const SizedBox(height: 20),
            const Text(
              'Litera',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'BACA. JELAJAH. BERKEMBANG.',
              style: TextStyle(color: Colors.white60, letterSpacing: 2),
            ),
            const SizedBox(height: 50),
            const Text(
              'Ratusan buku di\ngenggamanmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Mulai perjalanan membaca hari ini.\nTemukan buku yang tepat untukmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const Spacer(),
           ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (!context.mounted) return;
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Mulai Sekarang',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
