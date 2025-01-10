class ScannerConfig {
  const ScannerConfig({
    this.resolution = Resolution.hd720p,
    this.zxingOptions = const ZxingOptions(),
  });

  /// The resolution setting for the barcode scanner.
  final Resolution resolution;

  final ZxingOptions zxingOptions;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'resolution': resolution.value,
      'zxingOptions': zxingOptions.toMap(),
    };
  }
}

enum Resolution {
  sd480p(0),
  hd720p(1),
  hd1080p(2);

  const Resolution(this.value);
  final int value;
}

class ZxingOptions {
  const ZxingOptions({
    this.tryRotate = false,
    this.tryInvert = false,
    this.tryHarder = true,
    this.tryDownscale = false,
    this.maxNumberOfSymbols = 1,
    this.downscaleFactor = 3,
    this.downscaleThreshold = 500,
    this.tryCode39ExtendedMode = false,
    this.binarizer = Binarizer.localAverage,
  });

  /// If true, the scanner will attempt to rotate the image in 90° increments to find a barcode.
  ///
  /// Use this when:
  /// - Barcodes might be oriented in different directions
  /// - Scanning from different angles is common
  ///
  /// Performance Impact: Significant, as each rotation requires additional processing.
  final bool tryRotate;

  /// If true, the scanner will attempt to invert the image colors to find a barcode.
  ///
  /// Useful for:
  /// - Inverse barcodes (white on black background)
  /// - Dealing with different printing variations
  /// - Problematic lighting conditions
  ///
  /// Performance Impact: Moderate, requires an additional pass over the image.
  final bool tryInvert;

  /// If true, the scanner will use more advanced decoding techniques.
  ///
  /// This includes:
  /// - More thorough image analysis
  /// - Multiple decode attempts with different parameters
  /// - Enhanced pattern matching
  ///
  /// Performance Impact: Significant, but improves accuracy for difficult-to-read codes.
  final bool tryHarder;

  /// If true, the scanner will downscale the image before processing.
  ///
  /// Benefits:
  /// - Improved performance on high-resolution images
  /// - Reduced memory usage
  /// - Can help with noisy images
  ///
  /// Use in conjunction with [downscaleFactor] and [downscaleThreshold].
  final bool tryDownscale;

  /// Specifies the maximum number of barcodes to detect in a single scan.
  ///
  /// Set to:
  /// - 1 for single barcode detection (fastest)
  /// - >1 for multiple barcode detection
  /// - 0 for unlimited detection (slowest)
  final int maxNumberOfSymbols;

  /// The factor by which to downscale the image when [tryDownscale] is true.
  ///
  /// Higher values improve performance but may reduce accuracy.
  final int downscaleFactor;

  /// The minimum image dimension (in pixels) above which downscaling will be applied.
  ///
  /// Only applies when [tryDownscale] is true. Prevents unnecessary downscaling of already small images.
  final int downscaleThreshold;

  /// If true, enables extended mode for Code 39 format.
  ///
  /// Extended mode:
  /// - Supports full ASCII character set
  /// - Allows encoding of all 128 ASCII characters
  /// - May slightly impact performance
  ///
  /// Only relevant when scanning Code 39 barcodes.
  final bool tryCode39ExtendedMode;

  /// Determines the method used to convert the image to binary format.
  ///
  /// See [Binarizer] enum for detailed information about each method.
  final Binarizer binarizer;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tryRotate': tryRotate,
      'tryInvert': tryInvert,
      'tryHarder': tryHarder,
      'tryDownscale': tryDownscale,
      'maxNumberOfSymbols': maxNumberOfSymbols,
      'downscaleFactor': downscaleFactor,
      'downscaleThreshold': downscaleThreshold,
      'tryCode39ExtendedMode': tryCode39ExtendedMode,
      'binarizer': binarizer.value,
    };
  }
}

/// The `Binarizer` enum determines how the image is processed to convert it into a binary format (black and white)
/// suitable for barcode detection. Binarization is a crucial preprocessing step that significantly impacts
/// the scanner's ability to detect and decode barcodes accurately.
///
/// For more information about image binarization techniques:
/// - https://github.com/zxing/zxing/wiki/

enum Binarizer {
  /// Uses local average (adaptive) binarization, also known as Niblack-based binarization.
  ///
  /// This method calculates thresholds for each pixel based on the mean and standard deviation
  /// of its neighboring pixels. It's particularly effective for:
  /// - Images with varying lighting conditions
  /// - Documents with shadows or gradients
  /// - Barcodes on curved surfaces
  ///
  /// Performance Impact: Moderate to slow, but provides the best results for complex scenarios.
  localAverage(0),

  /// Uses global histogram-based binarization (Otsu's method).
  ///
  /// This method:
  /// - Analyzes the image's histogram to find an optimal global threshold
  /// - Works well with bimodal images (clear distinction between foreground and background)
  /// - Is more efficient than local methods
  ///
  /// Performance Impact: Fast, good balance between speed and accuracy for well-lit barcodes.
  ///
  globalHistogram(1),

  /// Uses a single fixed threshold value for the entire image.
  ///
  /// This simple method:
  /// - Applies the same threshold value to all pixels
  /// - Works best with high-contrast images
  /// - Is ideal for controlled lighting conditions
  ///
  /// Performance Impact: Very fast, but sensitive to lighting variations.
  fixedThreshold(2),

  /// Uses direct boolean casting of pixel values.
  ///
  /// This method:
  /// - Simply converts pixel values to binary based on a midpoint value
  /// - Provides minimal processing overhead
  /// - Best suited for perfect scanning conditions
  ///
  /// Performance Impact: Fastest method, but least adaptable to real-world conditions.
  boolCast(3);

  const Binarizer(this.value);
  final int value;
}
