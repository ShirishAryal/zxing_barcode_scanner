// Autogenerated from Pigeon (v22.7.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class ZxingBarcodeScannerError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "ZxingBarcodeScannerError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
      }
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let pigeonError = error as? ZxingBarcodeScannerError {
    return [
      pigeonError.code,
      pigeonError.message,
      pigeonError.details,
    ]
  }
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func createConnectionError(withChannelName channelName: String) -> ZxingBarcodeScannerError {
  return ZxingBarcodeScannerError(code: "channel-error", message: "Unable to establish connection on channel: '\(channelName)'.", details: "")
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// Generated class from Pigeon that represents data sent in messages.
struct BarcodeResult {
  var text: String? = nil
  var format: String? = nil


  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> BarcodeResult? {
    let text: String? = nilOrValue(pigeonVar_list[0])
    let format: String? = nilOrValue(pigeonVar_list[1])

    return BarcodeResult(
      text: text,
      format: format
    )
  }
  func toList() -> [Any?] {
    return [
      text,
      format,
    ]
  }
}

private class ZxingBarcodeScannerPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      return BarcodeResult.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class ZxingBarcodeScannerPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? BarcodeResult {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class ZxingBarcodeScannerPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return ZxingBarcodeScannerPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return ZxingBarcodeScannerPigeonCodecWriter(data: data)
  }
}

class ZxingBarcodeScannerPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = ZxingBarcodeScannerPigeonCodec(readerWriter: ZxingBarcodeScannerPigeonCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents Flutter messages that can be called from Swift.
protocol ZxingBarcodeScannerFlutterApiProtocol {
  func onScanSuccess(results resultsArg: [BarcodeResult], completion: @escaping (Result<Void, ZxingBarcodeScannerError>) -> Void)
}
class ZxingBarcodeScannerFlutterApi: ZxingBarcodeScannerFlutterApiProtocol {
  private let binaryMessenger: FlutterBinaryMessenger
  private let messageChannelSuffix: String
  init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "") {
    self.binaryMessenger = binaryMessenger
    self.messageChannelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
  }
  var codec: ZxingBarcodeScannerPigeonCodec {
    return ZxingBarcodeScannerPigeonCodec.shared
  }
  func onScanSuccess(results resultsArg: [BarcodeResult], completion: @escaping (Result<Void, ZxingBarcodeScannerError>) -> Void) {
    let channelName: String = "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerFlutterApi.onScanSuccess\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([resultsArg] as [Any?]) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(createConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = nilOrValue(listResponse[1])
        let details: String? = nilOrValue(listResponse[2])
        completion(.failure(ZxingBarcodeScannerError(code: code, message: message, details: details)))
      } else {
        completion(.success(Void()))
      }
    }
  }
}
/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol ZxingBarcodeScannerController {
  func toggleFlash() throws -> Bool
  func start() throws
  func stop() throws
  func dispose() throws
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class ZxingBarcodeScannerControllerSetup {
  static var codec: FlutterStandardMessageCodec { ZxingBarcodeScannerPigeonCodec.shared }
  /// Sets up an instance of `ZxingBarcodeScannerController` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: ZxingBarcodeScannerController?, messageChannelSuffix: String = "") {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let toggleFlashChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.toggleFlash\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      toggleFlashChannel.setMessageHandler { _, reply in
        do {
          let result = try api.toggleFlash()
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      toggleFlashChannel.setMessageHandler(nil)
    }
    let startChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.start\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      startChannel.setMessageHandler { _, reply in
        do {
          try api.start()
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      startChannel.setMessageHandler(nil)
    }
    let stopChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.stop\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      stopChannel.setMessageHandler { _, reply in
        do {
          try api.stop()
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      stopChannel.setMessageHandler(nil)
    }
    let disposeChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.dispose\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      disposeChannel.setMessageHandler { _, reply in
        do {
          try api.dispose()
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      disposeChannel.setMessageHandler(nil)
    }
  }
}
