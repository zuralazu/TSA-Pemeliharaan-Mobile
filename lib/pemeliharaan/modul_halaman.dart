import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_detail_halaman.dart';

class ModulHalaman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Pemeliharaan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih Jenis Modul Pemeliharaan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildModulCard(
                context,
                title: 'Modul APAR',
                modulType: 'sop_apar',
                color1: Colors.red.shade300,
                color2: Colors.red.shade700,
                icon: Icons.fire_extinguisher,
              ),
              const SizedBox(height: 20),
              _buildModulCard(
                context,
                title: 'Modul Fire Hydrant',
                modulType: 'sop_fire_hydrant',
                color1: Colors.blue.shade300,
                color2: Colors.blue.shade700,
                icon: Icons.water_drop_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulCard(
      BuildContext context, {
        required String title,
        required String modulType,
        required Color color1,
        required Color color2,
        required IconData icon,
      }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModulDetailHalaman(
              modulType: modulType,
              modulTitle: title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(icon, color: color2, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
