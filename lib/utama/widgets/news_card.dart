
import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String kategori;
  final Color kategoriColor;
  final IconData icon;
  final String judul;
  final String ringkasan;
  final String tanggal;
  final VoidCallback? onTap;

  const NewsCard({
    Key? key,
    required this.kategori,
    required this.kategoriColor,
    required this.icon,
    required this.judul,
    required this.ringkasan,
    required this.tanggal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDF0F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ikon kategori ─────────────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kategoriColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kategoriColor, size: 22),
              ),
              const SizedBox(width: 12),

              // ── Konten teks ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge kategori + tanggal
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kategoriColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kategori.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: kategoriColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tanggal,
                          style: TextStyle(
                              fontSize: 11.5, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ringkasan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
