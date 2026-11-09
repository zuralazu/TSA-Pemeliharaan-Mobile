import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroOnboardingPage extends StatefulWidget {
  const IntroOnboardingPage({super.key});

  @override
  State<IntroOnboardingPage> createState() => _IntroOnboardingPageState();
}

class _IntroOnboardingPageState extends State<IntroOnboardingPage> {
  static const _pages = [
    _IntroContent(
      title: 'Selamat datang di APK Tracker',
      description:
          'Kenali cara mudah menjaga alat proteksi kebakaran selalu siap digunakan.',
      icon: Icons.local_fire_department_rounded,
    ),
    _IntroContent(
      title: 'Kelola APAR dan Hydrant',
      description:
          'Temukan informasi aset, lokasi, dan status peralatan dalam satu daftar.',
      icon: Icons.inventory_2_rounded,
    ),
    _IntroContent(
      title: 'Inspeksi dengan QR',
      description:
          'Pindai kode QR pada aset untuk membuka informasi dan pemeriksaan yang sesuai.',
      icon: Icons.qr_code_scanner_rounded,
    ),
    _IntroContent(
      title: 'Catat setiap pemeriksaan',
      description:
          'Simpan hasil inspeksi agar riwayat dan tindak lanjut lebih mudah dipantau.',
      icon: Icons.fact_check_rounded,
    ),
  ];

  final _controller = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/entry');
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  key: const Key('intro-pages'),
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 280,
                            child: index == 0
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/animations/onboarding_scan.json',
                                        repeat: true,
                                        fit: BoxFit.contain,
                                      ),
                                      Container(
                                        width: 148,
                                        height: 148,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.16,
                                              ),
                                              blurRadius: 24,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 88,
                                          color: Color(0xFFE33B30),
                                        ),
                                      ),
                                    ],
                                  )
                                : _FeatureIllustration(icon: page.icon),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.55,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _pageIndex ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _pageIndex
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: isLastPage
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const Key('intro-register'),
                              onPressed: () => _finish('/register'),
                              style: _primaryButtonStyle,
                              child: const Text('Register'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              key: const Key('intro-login'),
                              onPressed: () => _finish('/login'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.white70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: _primaryButtonStyle,
                          child: const Text('Lanjutkan'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _primaryButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(Colors.white),
  foregroundColor: WidgetStatePropertyAll(Color(0xFF1976D2)),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
);

class _IntroContent {
  const _IntroContent({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _FeatureIllustration extends StatelessWidget {
  const _FeatureIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(56),
        ),
        child: Icon(icon, size: 112, color: const Color(0xFF1976D2)),
      ),
    );
  }
}
