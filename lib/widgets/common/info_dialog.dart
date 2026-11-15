import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String message;
  final IconData headerIcon;
  final List<Color> headerColors;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;

  const InfoDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.headerIcon,
    required this.headerColors,
    this.buttonLabel = 'Mengerti',
    this.onButtonPressed,
  });

  /// Shortcut untuk dialog error (merah).
  factory InfoDialog.error({
    Key? key,
    required String message,
    String buttonLabel = 'Mengerti',
    VoidCallback? onButtonPressed,
  }) {
    return InfoDialog(
      key: key,
      title: 'Peringatan',
      subtitle: 'Terjadi kesalahan',
      message: message,
      headerIcon: Icons.warning_rounded,
      headerColors: [Colors.red.shade500, Colors.red.shade700],
      buttonLabel: buttonLabel,
      onButtonPressed: onButtonPressed,
    );
  }

  /// Shortcut untuk dialog akses ditolak.
  factory InfoDialog.accessDenied({
    Key? key,
    required String message,
    VoidCallback? onButtonPressed,
  }) {
    return InfoDialog(
      key: key,
      title: 'Akses Ditolak',
      subtitle: 'Anda tidak memiliki hak akses',
      message: message,
      headerIcon: Icons.block_rounded,
      headerColors: [Colors.red.shade500, Colors.red.shade700],
      onButtonPressed: onButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageColor = headerColors.last;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header gradient ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerColors,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(headerIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Konten pesan ───────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: messageColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: messageColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: messageColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: messageColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 13,
                              color: messageColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Tombol aksi ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: headerColors),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: headerColors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper static untuk menampilkan dialog error langsung dari context.
  static Future<void> showError(
    BuildContext context,
    String message, {
    String buttonLabel = 'Mengerti',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => InfoDialog.error(
        message: message,
        buttonLabel: buttonLabel,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  /// Helper static untuk menampilkan dialog akses ditolak.
  static Future<void> showAccessDenied(
    BuildContext context,
    String message, {
    VoidCallback? onButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => InfoDialog.accessDenied(
        message: message,
        onButtonPressed: onButtonPressed,
      ),
    );
  }
}
