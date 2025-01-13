import Flutter
import UIKit

public class ZxingBarcodeScannerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = ZxingBarcodeScannerFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "com.shirisharyal.zxing_barcode_scanner")
    }
}

class ZxingBarcodeScannerFactory: NSObject, FlutterPlatformViewFactory {
    
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return ZxingBarcodeScannerPlatformView(frame: frame, viewId: viewId, args: args, binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class ZxingBarcodeScannerPlatformView: NSObject, FlutterPlatformView {
    private var scannerView: ZxingBarcodeScannerView
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        binaryMessenger: FlutterBinaryMessenger
    ) {
        scannerView = ZxingBarcodeScannerView(frame: frame, viewId: viewId, args: args, binaryMessenger: binaryMessenger)
        scannerView.view.frame = frame
        super.init()
    }

    func view() -> UIView {
        return scannerView.view
    }

}
