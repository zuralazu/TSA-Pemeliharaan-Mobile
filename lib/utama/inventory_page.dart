import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/barang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Barang> _barangs = [];
  List<Barang> _filteredBarangs = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarangs();
    _searchController.addListener(_onSearchChanged);
  }

  // ... di dalam class _InventoryPageState

  Future<void> fetchBarangs() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Mengambil token dengan kunci yang benar, yaitu 'access_token'
    String? token = prefs.getString('access_token');

    if (token == null) {
      // Jika tidak ada token, arahkan kembali ke halaman login
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
        return;
      }
    }

    // Menambahkan header otentikasi ke permintaan
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/barangs'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (mounted) {
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          _barangs = data.map((item) => Barang.fromJson(item)).toList();
          _filteredBarangs = _barangs;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Menangani kasus token tidak valid atau kedaluwarsa
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data barang: ${response.statusCode}')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBarangs = _barangs.where((barang) {
        return barang.nama.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildItemCard(Barang barang) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF42A5F5).withOpacity(0.15),
              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1976D2)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.nama,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Tipe: ${barang.tipe}', style: TextStyle(color: Colors.grey[600])),
                  Text('Jumlah: ${barang.jumlah}', style: TextStyle(color: Colors.grey[600])),
                  if (barang.kondisi != null)
                    Text('Kondisi: ${barang.kondisi}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBarangs.isEmpty
                ? Center(
              child: Text(
                "Barang tidak ditemukan 😕",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              itemCount: _filteredBarangs.length,
              itemBuilder: (context, index) {
                return _buildItemCard(_filteredBarangs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
