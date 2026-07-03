// lib/utama/shop_webview_halaman.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopWebViewHalaman extends StatefulWidget {
  final String url;
  final String title;

  const ShopWebViewHalaman({
    Key? key,
    this.url = 'https://tunassiakanugrah.com',
    this.title = 'Shop',
  }) : super(key: key);

  @override
  State<ShopWebViewHalaman> createState() => _ShopWebViewHalamanState();
}

class _ShopWebViewHalamanState extends State<ShopWebViewHalaman> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _isLoading = true;
  bool _gagalMemuat = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _gagalMemuat = false;
            });
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            setState(() {
              _isLoading = false;
              _gagalMemuat = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE2E8F0), height: 1),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_gagalMemuat)
              _buildErrorState()
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && !_gagalMemuat)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat halaman',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi internet kamu, lalu coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _gagalMemuat = false);
                _controller.reload();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}