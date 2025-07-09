import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';
import 'package:tunassiakanugrah/utama/dasbor_halaman.dart';
import 'package:tunassiakanugrah/auth/onboarding_page.dart';
import 'package:tunassiakanugrah/utama/notifikasi_page.dart';

void main() {
  runApp(const AplikasiSaya());
}

class AplikasiSaya extends StatelessWidget {
  const AplikasiSaya({super.key});

  Future<Widget> _cekLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    int? loginTime = prefs.getInt('login_timestamp');

    print('🔥 userData: $userData');
    print('🔥 loginTime: $loginTime');

    if (userData != null && loginTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final selisih = now - loginTime;

      print('🔥 selisih waktu login: ${selisih / 1000} detik');

      const batasWaktu = 15 * 60 * 1000; // 15 menit

      if (selisih <= batasWaktu) {
        print('✅ Sesi aktif. Masuk ke dashboard');
        return DasborHalaman();
      } else {
        print('❌ Sesi habis. Logout dan kembali ke onboarding');
        await prefs.remove('user_data');
        await prefs.remove('access_token');
        await prefs.remove('login_timestamp');
        return OnboardingPage();
      }
    } else {
      print('❌ Tidak ada data login. Masuk onboarding');
      return OnboardingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Widget>(
        future: _cekLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            return snapshot.data ?? OnboardingPage();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DasborHalaman(),
        '/notifikasi': (context) => NotifikasiPage(),
      },
    );
  }
}
