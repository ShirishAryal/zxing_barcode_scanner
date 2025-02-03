import AVFoundation
import Flutter
import UIKit
import ZXingCpp

class ZxingBarcodeScannerView: UIViewController, ZxingBarcodeScannerController {
    private let flutterApi: ZxingBarcodeScannerFlutterApi
    private let captureSession: AVCaptureSession
    private let processingQueue = DispatchQueue(label: "com.zxing_barcode_scanner.ios.processing", qos: .userInitiated)
    private let cameraQueue = DispatchQueue(label: "com.zxing_barcode_scanner.ios.camera", qos: .userInitiated)
    private let reader: ZXIBarcodeReader
    private let zxingLock = DispatchSemaphore(value: 1)
    
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    init(frame: CGRect,
         viewId: Int64,
         config: ScannerConfig,
         binaryMessenger: FlutterBinaryMessenger) {
        self.flutterApi = ZxingBarcodeScannerFlutterApi(binaryMessenger: binaryMessenger)
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = config.resolution
        
        self.reader = {
            let reader = ZXIBarcodeReader()
            let options = reader.options
            options.tryDownscale = config.zxingOptions.tryDownscale
            options.tryHarder = config.zxingOptions.tryHarder
            options.maxNumberOfSymbols = config.zxingOptions.maxNumberOfSymbols
            options.tryRotate = config.zxingOptions.tryRotate
            options.downscaleFactor = UInt8(config.zxingOptions.downScaleFactor)
            options.tryCode39ExtendedMode = config.zxingOptions.tryCode39ExtendedMode
            options.formats = config.zxingOptions.formats.map { NSNumber(value: $0) }
            return reader
        }()
        
        super.init(nibName: nil, bundle: nil)
        ZxingBarcodeScannerControllerSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayer()
        requestCameraAccess()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        self.preview.removeFromSuperlayer()
    }
    
    private func setupPreviewLayer() {
        preview.frame = view.layer.bounds
        view.layer.addSublayer(preview)
    }
    
    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCameraSession()
                } else {
                    self?.handleCameraPermissionDenied()
                }
            }
        case .authorized:
            setupCameraSession()
        default:
            handleCameraPermissionDenied()
        }
    }
    
    private func handleCameraPermissionDenied() {
        DispatchQueue.main.async {
            self.flutterApi.onError(error: ZxingBarcodeScannerException(
                tag: "Permission_Denied",
                message: "Camera Permission Denied",
                detail: "Make sure to provide camera permission in your app settings"
            ), completion: { _ in })
        }
    }
    
    private func setupCameraSession() {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            self.configureCameraInput()
            self.configureVideoOutput()
            self.captureSession.startRunning()
        }
    }
    
    private func configureCameraInput() {
        guard let device = getBestCamera() else {
            DispatchQueue.main.async {
                self.flutterApi.onError(error: ZxingBarcodeScannerException(
                    tag: "CAMERA_NOT_FOUND",
                    message: "Could not find a camera",
                    detail: "Make sure your device has a camera"
                ), completion: { _ in })
            }
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                captureSession.commitConfiguration()
            } else {
                captureSession.commitConfiguration()
                print("Failed to add camera input")
            }
        } catch {
            print("Error setting up camera input: \(error)")
            captureSession.commitConfiguration()
        }
    }
    
    private func configureVideoOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        captureSession.beginConfiguration()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        captureSession.commitConfiguration()
    }
    
    private func getBestCamera() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: getAvailableCameraTypes(),
            mediaType: .video,
            position: .back
        )
        return discoverySession.devices.first
    }
    
    private func getAvailableCameraTypes() -> [AVCaptureDevice.DeviceType] {
        if #available(iOS 13.0, *) {
            return [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ]
        } else {
            return [
                .builtInDualCamera,
                .builtInWideAngleCamera
            ]
        }
    }
}

extension ZxingBarcodeScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard zxingLock.wait(timeout: .now()) == .success else {
            return // Drop frame if the previous one is still being processed
        }
        
        defer { zxingLock.signal() } // Release the lock after
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if let results = try? self.reader.read(imageBuffer), !results.isEmpty {
            let scanResults = results.map { BarcodeResult(text: $0.text, format: self.getFormat(val: $0.format.rawValue)) }
            
            DispatchQueue.main.async {
                self.flutterApi.onScanSuccess(results: scanResults) { _ in }
            }
        }
    }
    
    private func getFormat(val: Int) -> String {
        switch val {
        case 1: return "aztec"
        case 2: return "codabar"
        case 3: return "code39"
        case 4: return "code93"
        case 5: return "code128"
        case 6: return "dataBar"
        case 7: return "dataBarExpanded"
        case 8: return "dataMatrix"
        case 9: return "ean8"
        case 10: return "ean13"
        case 11: return "itf"
        case 13: return "pdf417"
        case 14: return "qrCode"
        case 15: return "microQRCode"
        case 16: return "rmqrCode"
        case 17: return "upcA"
        case 18: return "upcE"
        default: return "unknown"
        }
    }
}

extension ZxingBarcodeScannerView {
    func start() throws {
        if captureSession.isRunning { return }
        cameraQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stop() throws {
        if !captureSession.isRunning { return }
        cameraQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    func toggleFlash() throws -> Bool {
        guard captureSession.isRunning, let device = getBestCamera(), device.hasTorch else {
            return false
        }
        
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        if device.isTorchModeSupported(.on) {
            device.torchMode = device.torchMode == .on ? .off : .on
            return device.torchMode == .on
        } else {
            print("Torch mode not supported")
        }
        return device.torchMode == .on
    }
    
    func dispose() throws {
        // Ensure the session stops on the main queue
        DispatchQueue.main.async {
            self.captureSession.stopRunning()

            // Remove inputs and outputs
            self.captureSession.inputs.forEach { input in
                self.captureSession.removeInput(input)
            }
            self.captureSession.outputs.forEach { output in
                self.captureSession.removeOutput(output)
            }
        }
    }
}
