// lib/main.dart
import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/auth/onboarding_page.dart';

void main() {
  runApp(AplikasiSaya());
}

class AplikasiSaya extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Tracker', // UBAH: Judul aplikasi menjadi "APK Tracker"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: OnboardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}