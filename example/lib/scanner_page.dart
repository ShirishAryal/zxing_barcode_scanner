import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zxing_barcode_scanner/zxing_barcode_scanner.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Center(
        child: ZxingBarcodeScanner(
          onScan: (results) {
            for (final result in results) {
              log('Barcode Data: ${result.format ?? ''}');
              log('Barcode Type: ${result.text ?? ''}');
            }
          },
        ),
      ),
    );
  }
}
