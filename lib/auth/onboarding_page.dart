// lib/auth/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // Menggunakan Stack untuk layering efek visual
        children: [
          // Latar belakang gradient dominan biru
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Gradient dari atas ke bawah
                end: Alignment.bottomCenter,
                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], // Biru muda ke biru tua
              ),
            ),
          ),
          // Elemen dekoratif abstrak (opsional, bisa diganti gambar)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Konten utama di tengah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0), // Padding lebih besar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Konten di bagian bawah
              crossAxisAlignment: CrossAxisAlignment.center, // Rata tengah horizontal
              children: [
                // Area ilustrasi/logo aplikasi yang lebih besar dan menarik
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ilustrasi atau logo APK Tracker
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9), // Latar putih semi-transparan
                          borderRadius: BorderRadius.circular(90), // Bentuk lingkaran
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_fire_department_outlined, // Ikon APAR yang relevan
                            size: 100, // Ukuran ikon yang menonjol
                            color: Colors.red.shade800, // Warna merah api yang kuat
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'APK Tracker', // Nama aplikasi di sini
                        style: TextStyle(
                          fontSize: 42, // Ukuran font besar
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Warna teks putih bersih
                          letterSpacing: 1.5, // Sedikit jarak antar huruf
                          shadows: [ // Efek bayangan pada teks
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Solusi Pemantauan Alat Proteksi Kebakaran Terintegrasi', // Slogan/deskripsi singkat
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60), // Jarak ke tombol

                // Tombol Login (lebih premium)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Sudut sangat membulat
                      ),
                      backgroundColor: Colors.white, // Warna tombol putih
                      elevation: 8, // Bayangan lebih jelas
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20, color: Colors.blue.shade700, fontWeight: FontWeight.bold), // Teks biru kuat
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Tombol Register (lebih premium)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.white, width: 2), // Border putih yang jelas
                      backgroundColor: Colors.transparent, // Latar belakang transparan
                      elevation: 0, // Tanpa bayangan
                    ),
                    child: Text(
                      'Daftar Akun Baru', // Teks yang lebih spesifik
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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