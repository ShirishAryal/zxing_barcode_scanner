# ZXing Barcode Scanner

A Flutter plugin that implements barcode scanning using [ZXing-cpp](https://github.com/zxing-cpp/zxing-cpp) on both Android and iOS platforms. While iOS's AVFoundation offers good scanning performance, it can struggle with densely printed QR codes or those with uneven print quality. This plugin is created to address these limitations as well as those of MLKit barcode scanning, particularly for high-density QR codes and challenging lighting conditions, while eliminating the dependency on Google Play Services.

## Installation

```yaml
dependencies:
  zxing_barcode_scanner: ^1.0.0
```

### Android

```
minSdkVersion 21
```

### iOS

```
<key>NSCameraUsageDescription</key>
<string>This app requires access to your camera scanning barcodes</string>
```

## Basic Usage

```dart
import 'package:zxing_barcode_scanner/zxing_barcode_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ZxingBarcodeScannerController _controller;

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
      appBar: AppBar(),
      body: Center(
        child: ZxingBarcodeScanner(
          onError: (error) => Center(
            child: Text(error.message ?? ''),
          ),
          config: const ScannerConfig(
            resolution: Resolution.hd720p,
            zxingOptions: ZxingOptions(
              tryRotate: true,
              tryInvert: true,
              tryHarder: true,
              tryDownscale: false,
              binarizer: Binarizer.localAverage,
            ),
          ),
          onScan: (results) async {
            for(result in results){
                print(result.text??'')
            }
          },
        ),
      ),
    );
  }
}
```

```dart
// Start scanner
await _controller.start()

// Stop scanner
await _controller.stop()
```

## Advanced Configuration

### Resolution Options

```dart
Resolution.sd480p    // 640x480
Resolution.hd720p    // 1280x720
Resolution.hd1080p   // 1920x1080
```

### Binarizer Methods

```dart
Binarizer.localAverage     // Best for varying lighting
Binarizer.globalHistogram  // Fast and balanced
Binarizer.fixedThreshold   // Fast, needs good lighting
Binarizer.boolCast        // Fastest, ideal conditions only
```

### Performance Optimization

```dart
ZxingOptions(
  tryDownscale: true,
  downscaleFactor: 3,
  downscaleThreshold: 500,
  tryHarder: false,
  maxNumberOfSymbols: 1,
)
```

## Performance Tips

1. **Choose the Right Resolution**: Higher isn't always better
2. **Select Appropriate Binarizer**: Match to your use case
3. **Enable Downscaling**: For better performance on high-res images
4. **Optimize Options**: Adjust based on your specific needs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Based on the [ZXing-cpp](https://github.com/nu-book/zxing-cpp) library
- Inspired by the need for a reliable, platform-independent barcode scanner
