import AVFoundation
import Flutter
import UIKit
import ZXingCpp

class ZxingBarcodeScannerView: UIViewController, ZxingBarcodeScannerController{
    private let flutterApi: ZxingBarcodeScannerFlutterApi
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        return session
    }()
    
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private let queue = DispatchQueue(label: "com.zxing_cpp.ios", qos: .userInitiated)
    
    init(frame: CGRect,
         viewId: Int64,
         args: Any?,
         binaryMessenger: FlutterBinaryMessenger) {
        self.flutterApi = ZxingBarcodeScannerFlutterApi(binaryMessenger: binaryMessenger)
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
    
    private func setupPreviewLayer() {
        preview.frame = view.layer.bounds
        view.layer.addSublayer(preview)
    }
}

extension ZxingBarcodeScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                self?.setupCameraSession()
            }
        case .authorized:
            setupCameraSession()
        default:
                flutterApi.onError(error: ZxingBarcodeScannerException(
                    tag: "Permission_Denied",
                    message: "Camera Permission Denied",
                    detail: "Make sure to provide camera premission in your app settings"),
                    completion: {result in}
                )
            break
        }
    }
    
    private func setupCameraSession() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.configureCameraInput()
            self.configureVideoOutput()
            self.captureSession.startRunning()
        }
    }
    
    private func configureCameraInput() {
        guard let device = getBestCamera() else { return }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            captureSession.commitConfiguration()
            return
        }
    }
    
    private func configureVideoOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: queue)
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
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

extension ZxingBarcodeScannerView{
    func start() throws {
        if(captureSession.isRunning) {return}
        queue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stop() throws {
        if(!captureSession.isRunning) {return}
        queue.async {
            self.captureSession.stopRunning()
        }
    }
    
    func toggleFlash() throws -> Bool{
        if(!captureSession.isRunning) {return false}
        
        let device = getBestCamera()
        if(!(device?.hasTorch ?? false)){
            print("Flash not supported")
            return false
        }
        try device?.lockForConfiguration()
        device?.torchMode = (device?.torchMode == .on) ? .off : .on
        device?.unlockForConfiguration()
        return (device?.torchMode ?? .off) == .on
    }
    
    func dispose() throws {
        if(!captureSession.isRunning) {return}
        queue.async {
            self.captureSession.stopRunning()
        }
    }
}
