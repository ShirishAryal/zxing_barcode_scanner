import 'package:flutter/material.dart';
import 'package:zxing_barcode_scanner/zxing_barcode_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ZxingBarcodeScannerController _controller;
  bool _isProcessingQR = false;

  @override
  void initState() {
    _controller = ZxingBarcodeScannerController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Center(
        child: ZxingBarcodeScanner(
          onError: (error) => Center(
            child: Text(error.message ?? ''),
          ),
          overlay: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
          onScan: (results) async {
            if (_isProcessingQR) return;
            _isProcessingQR = true;
            await _controller.stop();
            if (!context.mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerResultPage(results: results),
              ),
            );
            _isProcessingQR = false;
            await _controller.start();
          },
        ),
      ),
    );
  }
}

class ScannerResultPage extends StatelessWidget {
  const ScannerResultPage({super.key, required this.results});
  final List<BarcodeResult> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final result in results)
                ListTile(
                  leading: Text(
                    result.format.toString(),
                    style: TextStyle(color: Colors.blue),
                  ),
                  title: Text(result.text ?? ''),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
