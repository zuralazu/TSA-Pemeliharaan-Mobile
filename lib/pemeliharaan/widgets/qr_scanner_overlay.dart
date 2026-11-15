import 'package:flutter/material.dart';

class QrScannerOverlay extends StatelessWidget {
  final Animation<double> animation;
  final bool isFlashOn;
  final VoidCallback onToggleFlash;
  final VoidCallback onSwitchCamera;

  const QrScannerOverlay({
    super.key,
    required this.animation,
    required this.isFlashOn,
    required this.onToggleFlash,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Posisikan kode QR pada kotak yang disediakan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 5, color: Colors.black)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // ── Kotak scanner + garis animasi ─────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 250 * (animation.value - 0.5)),
                      child: Container(
                          width: 240, height: 3, color: Colors.redAccent),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // ── Tombol Flash ───────────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: onToggleFlash,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            label: Text(
              isFlashOn ? 'Flash On' : 'Flash Off',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          // ── Tombol Ganti Kamera ────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: onSwitchCamera,
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            label: const Text('Ganti Kamera',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
