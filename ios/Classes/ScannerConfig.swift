import AVFoundation
import Foundation

// MARK: - Binarizer Enum

enum Binarizer: Int, Codable {
    case localAverage = 0
    case globalHistogram = 1
    case fixedThreshold = 2
    case boolCast = 3
}

// MARK: - ZxingOptions Struct

struct ZxingOptions: Codable {
    var tryRotate: Bool
    var tryInvert: Bool
    var tryHarder: Bool
    var tryDownscale: Bool
    var downScaleFactor: Int
    var maxNumberOfSymbols: Int
    var tryCode39ExtendedMode: Bool
    var binarizer: Binarizer
    var formats: [Int32]

    // Initializer from Dictionary
    init(fromMap map: [String: Any]) {
        self.tryRotate = map["tryRotate"] as? Bool ?? true
        self.tryInvert = map["tryInvert"] as? Bool ?? true
        self.tryHarder = map["tryHarder"] as? Bool ?? true
        self.tryDownscale = map["tryDownscale"] as? Bool ?? true
        self.downScaleFactor = map["downScaleFactor"] as? Int ?? 1
        self.maxNumberOfSymbols = map["maxNumberOfSymbols"] as? Int ?? 1
        self.tryCode39ExtendedMode = map["tryCode39ExtendedMode"] as? Bool ?? false
        self.binarizer = Binarizer(rawValue: map["binarizer"] as? Int ?? 0) ?? .localAverage
        self.formats = map["formats"] as? [Int32] ?? []
    }

    // Method to convert to Dictionary
    func toMap() -> [String: Any] {
        return [
            "tryRotate": tryRotate,
            "tryInvert": tryInvert,
            "tryHarder": tryHarder,
            "tryDownscale": tryDownscale,
            "maxNumberOfSymbols": maxNumberOfSymbols,
            "binarizer": binarizer.rawValue,
            "formats": formats,
            "downScaleFactor": downScaleFactor,
            "tryCode39ExtendedMode": tryCode39ExtendedMode,
        ]
    }

    // Default initializer
    init(
        tryRotate: Bool = true,
        tryInvert: Bool = true,
        tryHarder: Bool = true,
        tryDownscale: Bool = true,
        maxNumberOfSymbols: Int = 1,
        binarizer: Binarizer = .localAverage,
        formats: [Int32] = [],
        downScaleFactor: Int = 1,
        tryCode39ExtendedMode: Bool = false
    ) {
        self.tryRotate = tryRotate
        self.tryInvert = tryInvert
        self.tryHarder = tryHarder
        self.tryDownscale = tryDownscale
        self.maxNumberOfSymbols = maxNumberOfSymbols
        self.binarizer = binarizer
        self.formats = formats
        self.downScaleFactor = downScaleFactor
        self.tryCode39ExtendedMode = tryCode39ExtendedMode
    }
}

// MARK: - ScannerConfig Struct

struct ScannerConfig {
    var resolution: AVCaptureSession.Preset
    var zxingOptions: ZxingOptions
    var ignoreEdges: Bool

    // Initializer from Dictionary
    init(fromMap map: [String: Any]) {
        self.resolution = ScannerConfig.resolution(from: map["resolution"] as? Int)
        self.zxingOptions = ZxingOptions(fromMap: map["zxingOptions"] as? [String: Any] ?? [:])
        self.ignoreEdges = map["ignoreEdges"] as? Bool ?? true
    }

    // Method to convert to Dictionary
    func toMap() -> [String: Any] {
        return [
            "resolution": ScannerConfig.resolutionValue(for: resolution),
            "zxingOptions": zxingOptions.toMap(),
            "ignoreEdges": ignoreEdges,
        ]
    }

    // Default initializer
    init(
        resolution: AVCaptureSession.Preset = .hd1280x720,
        zxingOptions: ZxingOptions = ZxingOptions(),
        ignoreEdges: Bool = true
    ) {
        self.resolution = resolution
        self.zxingOptions = zxingOptions
        self.ignoreEdges = ignoreEdges
    }

    // Helper to convert resolution Int to AVCaptureSession.Preset
    private static func resolution(from value: Int?) -> AVCaptureSession.Preset {
        switch value {
        case 0: return .vga640x480
        case 1: return .hd1280x720
        case 2: return .hd1920x1080
        default: return .hd1280x720
        }
    }

    // Helper to convert AVCaptureSession.Preset to resolution Int
    private static func resolutionValue(for preset: AVCaptureSession.Preset) -> Int {
        switch preset {
        case .vga640x480: return 0
        case .hd1280x720: return 1
        case .hd1920x1080: return 2
        default: return 1  // Default to .hd1280x720
        }
    }
}
