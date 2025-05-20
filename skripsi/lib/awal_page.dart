// lib/awal_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan file HomePage sudah ada

class AwalPage extends StatelessWidget {
  const AwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ellipse atas
          Positioned(
            top: -70, // Posisi atas untuk ellipse pertama
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(
                    142, 206, 255, 1.0), // Warna biru muda untuk ellipse
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10, // Posisi atas untuk ellipse pertama
            right: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(
                    142, 206, 255, 1.0), // Warna biru muda untuk ellipse
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Ellipse bawah
          Positioned(
            bottom: -100, // Posisi bawah untuk ellipse kedua
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(
                    142, 206, 255, 1.0), // Warna biru muda untuk ellipse
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 10, // Posisi bawah untuk ellipse kedua
            left: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(
                    142, 206, 255, 1.0), // Warna biru muda untuk ellipse
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Konten utama
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Text
                const SizedBox(height: 50),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Untirta',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(11, 90, 183, 1.0),
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2), // Posisi bayangan
                              blurRadius: 2, // Efek blur bayangan
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: '-Ku',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(229, 204, 5, 1.0),
                          shadows: [
                            Shadow(
                              offset: Offset(3, 3), // Posisi bayangan
                              blurRadius: 5, // Efek blur bayangan
                              color: Colors.black54,
                            ),
                          ], // Warna berbeda untuk "-Ku"
                        ),
                      ),
                    ],
                  ),
                ),
                // Splash water image
                Image.asset(
                  'assets/water_splash.png',
                  height: 250,
                  width: 250,
                ), // Tambahkan gambar splash
                const SizedBox(height: 20),
                // Tombol Get Started
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman HomePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
