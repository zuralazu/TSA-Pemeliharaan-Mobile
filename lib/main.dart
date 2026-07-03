import 'dart:io'; // ⬅️ WAJIB
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';
import 'package:tunassiakanugrah/utama/dasbor_halaman.dart';
import 'package:tunassiakanugrah/auth/onboarding_page.dart';
import 'package:tunassiakanugrah/utama/notifikasi_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ⚠️ DEV ONLY SSL BYPASS
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const AplikasiSaya());
}

class AplikasiSaya extends StatelessWidget {
  const AplikasiSaya({super.key});

  Future<Widget> _cekLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    int? loginTime = prefs.getInt('login_timestamp');

    if (userData != null && loginTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final selisih = now - loginTime;

      const batasWaktu = 15 * 60 * 1000; // 15 menit

      if (selisih <= batasWaktu) {
        return DasborHalaman();
      } else {
        await prefs.remove('user_data');
        await prefs.remove('access_token');
        await prefs.remove('login_timestamp');
        return OnboardingPage();
      }
    } else {
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
