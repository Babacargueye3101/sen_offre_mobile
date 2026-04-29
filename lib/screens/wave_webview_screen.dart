import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WaveWebViewScreen extends StatefulWidget {
  final String waveUrl;
  final String checkoutId;
  final Function(bool success, String? message) onPaymentComplete;

  const WaveWebViewScreen({
    super.key,
    required this.waveUrl,
    required this.checkoutId,
    required this.onPaymentComplete,
  });

  @override
  State<WaveWebViewScreen> createState() => _WaveWebViewScreenState();
}

class _WaveWebViewScreenState extends State<WaveWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.waveUrl));
  }

  void _checkPaymentStatus(String url) {
    // Vérifier si l'URL indique un succès ou un échec
    if (url.contains('success') || url.contains('payment-success')) {
      widget.onPaymentComplete(true, 'Paiement réussi');
      Navigator.pop(context, true);
    } else if (url.contains('cancel') || url.contains('error') || url.contains('failed')) {
      widget.onPaymentComplete(false, 'Paiement annulé ou échoué');
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFFF),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _showCancelDialog();
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/wave_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.waves,
                  color: Colors.white,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Paiement Wave',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFFF)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chargement du paiement Wave...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le paiement'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce paiement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              widget.onPaymentComplete(false, 'Paiement annulé par l\'utilisateur');
              Navigator.pop(context, false); // Fermer le WebView
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
