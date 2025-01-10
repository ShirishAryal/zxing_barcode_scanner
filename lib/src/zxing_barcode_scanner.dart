import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zxing_barcode_scanner/generated/zxing_barcode_scanner_api.g.dart';

const _viewType = 'com.shirisharyal.zxing_barcode_scanner';

class ZxingBarcodeScanner extends StatefulWidget {
  const ZxingBarcodeScanner({
    super.key,
    required this.onScan,
    required this.onError,
  });

  final void Function(List<BarcodeResult> results) onScan;
  final Widget Function(ZxingBarcodeScannerException error) onError;

  @override
  State<ZxingBarcodeScanner> createState() => _ZxingBarcodeScannerState();
}

class _ZxingBarcodeScannerState extends State<ZxingBarcodeScanner> implements ZxingBarcodeScannerFlutterApi {
  ZxingBarcodeScannerException? _error;
  // TODO: Implement the barcode scanner creation parameters
  final _creationParams = <String, dynamic>{};

  @override
  void initState() {
    ZxingBarcodeScannerFlutterApi.setUp(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.onError(_error!);
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      TargetPlatform.iOS => UiKitView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      _ => throw UnimplementedError(),
    };
  }

  @override
  void onScanSuccess(List<BarcodeResult> results) {
    widget.onScan(results);
  }

  @override
  void onError(ZxingBarcodeScannerException? error) {
    _error = error;
    setState(() {});
  }
}
