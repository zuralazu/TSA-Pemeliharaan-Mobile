// lib/pemeliharaan/modul_halaman.dart
import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_detail_halaman.dart';

class ModulHalaman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Pemeliharaan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white, // UBAH INI: Warna ikon dan teks kembali menjadi putih
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade200],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pilih Jenis Modul Pemeliharaan:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),

                _buildModulCardButton(
                  context,
                  'Modul APAR',
                  'sop_apar',
                  Colors.red,
                  Icons.fire_extinguisher,
                ),
                SizedBox(height: 25),

                _buildModulCardButton(
                  context,
                  'Modul Fire Hydrant',
                  'sop_fire_hydrant',
                  Colors.blue,
                  Icons.water_drop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModulCardButton(BuildContext context, String title, String modulType, MaterialColor color, IconData icon) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulDetailHalaman(modulType: modulType, modulTitle: title),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.shade400, color.shade800],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}