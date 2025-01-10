import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/generated/zxing_barcode_scanner_api.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'ios/Classes/ZxingBarcodeScanner.swift',
    swiftOptions: SwiftOptions(errorClassName: 'ZxingBarcodeScannerError'),
    kotlinOut: 'android/src/main/kotlin/com/shirisharyal/zxing_barcode_scanner/ZxingBarcodeScanner.kt',
    kotlinOptions: KotlinOptions(errorClassName: 'ZxingBarcodeScannerError'),
  ),
)
@FlutterApi()
abstract class ZxingBarcodeScannerFlutterApi {
  void onScanSuccess(List<BarcodeResult> results);
  void onError(ZxingBarcodeScannerException? error);
}

@HostApi()
abstract class ZxingBarcodeScannerController {
  bool toggleFlash();
  void start();
  void stop();
  void dispose();
}

class BarcodeResult {
  String? text;
  String? format;
}

class ZxingBarcodeScannerException {
  String? tag;
  String? message;
  String? detail;
}
