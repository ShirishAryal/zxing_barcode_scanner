import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zxing_barcode_scanner/generated/zxing_barcode_scanner_api.g.dart';
import 'package:zxing_barcode_scanner/src/scanner_config.dart';

const _viewType = 'com.shirisharyal.zxing_barcode_scanner';

class ZxingBarcodeScanner extends StatefulWidget {
  const ZxingBarcodeScanner({
    super.key,
    this.config = const ScannerConfig(),
    required this.onError,
    required this.onScan,
    this.overlay,
  });

  final void Function(List<BarcodeResult> results) onScan;
  final Widget Function(ZxingBarcodeScannerException error) onError;
  final ScannerConfig config;
  final Widget? overlay;

  @override
  State<ZxingBarcodeScanner> createState() => _ZxingBarcodeScannerState();
}

class _ZxingBarcodeScannerState extends State<ZxingBarcodeScanner> implements ZxingBarcodeScannerFlutterApi {
  ZxingBarcodeScannerException? _error;

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

    final creationParams = widget.config.toMap();
    final child = switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      TargetPlatform.iOS => UiKitView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      _ => throw UnimplementedError(),
    };
    if (widget.overlay == null) return child;
    return Stack(
      children: [
        child,
        widget.overlay!,
      ],
    );
  }

  @override
  void onScanSuccess(List<BarcodeResult> results) => widget.onScan(results);

  @override
  void onError(ZxingBarcodeScannerException? error) => setState(() => _error = error);
}
