import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/beranda_page.dart'; // <--- Bagian ini yang disesuaikan!

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Flutter Saya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BerandaPage(), // Set BerandaPage sebagai halaman awal
    );
  }
}