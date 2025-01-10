package com.shirisharyal.zxing_barcode_scanner

import BarcodeResult
import ZxingBarcodeScannerController
import ZxingBarcodeScannerException
import ZxingBarcodeScannerFlutterApi
import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.util.Size
import android.view.Surface
import android.view.View
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import zxingcpp.BarcodeReader
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class ScannerView(
    private val context: Context,
    private val activity: Activity,
    private val activityPluginBinding: ActivityPluginBinding,
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val scannerConfig: ScannerConfig
) : PlatformView, PluginRegistry.RequestPermissionsResultListener, ZxingBarcodeScannerController {

    private var camera: androidx.camera.core.Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysisBuilder: ImageAnalysis? = null
    private var barcodeReader: BarcodeReader? = null
    private var cameraExecutor: ExecutorService? = null
    private var isFlashOn = false
    private var zxingBarcodeScannerFlutterApi: ZxingBarcodeScannerFlutterApi = ZxingBarcodeScannerFlutterApi(flutterPluginBinding.binaryMessenger)

    companion object {
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
        private val defaultBoundSize = Size(1280, 720)
        private const val TAG = "ZxingBarcodeScanner"
        private val resolutionSelector =  ResolutionSelector.Builder().setResolutionStrategy(
            ResolutionStrategy(
                defaultBoundSize,
                ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER
            )
        ) .setAspectRatioStrategy(
            AspectRatioStrategy.RATIO_16_9_FALLBACK_AUTO_STRATEGY
        )
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
    }

    private val preview = PreviewView(context).apply {
        scaleType = PreviewView.ScaleType.FIT_CENTER
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    }

    override fun getView(): View = preview

    init {
        ZxingBarcodeScannerController.setUp(flutterPluginBinding.binaryMessenger, this)
        activityPluginBinding.addRequestPermissionsResultListener(this)

        if(allPermissionsGranted()){
            startCamera()
        }
        else {
            ActivityCompat.requestPermissions(
                activity,
                REQUIRED_PERMISSIONS,
                REQUEST_CODE_PERMISSIONS
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String?>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != REQUEST_CODE_PERMISSIONS) return false
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            zxingBarcodeScannerFlutterApi.onError(ZxingBarcodeScannerException(
                tag = "PERMISSION_DENIED",
                message = "Camera permission denied",
                detail = "Camera permission denied permanently")){}
        }
        return true
    }

    private fun startCamera() {
        ProcessCameraProvider.getInstance(context).apply {
            addListener({
                cameraProvider = get()
                cameraProvider?.unbindAll()

                val previewUseCase = Preview.Builder()
                    .setResolutionSelector(resolutionSelector.build())
                    .build()
                    .also {
                        it.surfaceProvider = preview.surfaceProvider
                    }

                setupBarcodeReader()
                setupImageAnalysis()
                cameraExecutor = Executors.newSingleThreadExecutor()
                try {
                    cameraProvider?.apply {
                        unbindAll()
                        camera = bindToLifecycle(
                            activity as LifecycleOwner,
                            CameraSelector.Builder()
                                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                                .build(),
                            previewUseCase,
                            imageAnalysisBuilder
                        )
                    }

                    imageAnalysisBuilder?.setAnalyzer(cameraExecutor!!) {
                        scanBarcodes(it)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }, ContextCompat.getMainExecutor(context))
        }

    }


    private fun setupImageAnalysis() {
        imageAnalysisBuilder = ImageAnalysis.Builder()
            .setResolutionSelector(resolutionSelector.build())
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_BLOCK_PRODUCER)
            .setImageQueueDepth(4)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
            .setTargetRotation(Surface.ROTATION_0)
            .build()

    }

    private fun setupBarcodeReader() {
      val options = BarcodeReader.Options().apply {
            formats = setOf(BarcodeReader.Format.QR_CODE)
            tryInvert = scannerConfig.zxingOptions.tryInvert
            tryHarder = scannerConfig.zxingOptions.tryHarder
            tryDownscale = scannerConfig.zxingOptions.tryDownscale
            maxNumberOfSymbols = scannerConfig.zxingOptions.maxNumberOfSymbols
            binarizer = scannerConfig.zxingOptions.binarizer
            // Need more testing either enabling [tryRotate] flag
            // or enabling rotation on imageAnalysisBuilder is more effective
            tryRotate = scannerConfig.zxingOptions.tryRotate
        }
      barcodeReader = BarcodeReader(options)
    }

    private fun scanBarcodes(imageProxy: ImageProxy) {
        val start = System.currentTimeMillis()
        val results = barcodeReader?.read(imageProxy)
        imageProxy.close()
        if(results.isNullOrEmpty()) return
        val end = System.currentTimeMillis()
        Log.d(TAG, "Time taken to scan: ${end - start}ms")
        val barcodeResults : MutableList<BarcodeResult> = emptyList<BarcodeResult>().toMutableList()
        for (result in results) {
            if(result.text.isNullOrEmpty()) return
            Log.d(TAG, "Barcode: ${result.text}")
            barcodeResults.add(BarcodeResult(result.text!!, format = result.format.name))
        }
        if(barcodeResults.isEmpty()) return
        activity.runOnUiThread {
            zxingBarcodeScannerFlutterApi.onScanSuccess(barcodeResults){
                it.onSuccess {
                    val overAllTime = System.currentTimeMillis()
                    Log.d(TAG, "Time taken to scan and transfer to flutter side: ${overAllTime - start}ms")
                    Log.d(TAG, "Successfully sent codes to Flutter")
                }.onFailure { error ->
                    Log.e(TAG, "Error sending codes to Flutter", error)
                }
            }
        }
    }

    override fun toggleFlash(): Boolean {
        val hasFlash = camera?.cameraInfo?.hasFlashUnit() == true
        if (!hasFlash) return  false
       camera?.cameraControl?.enableTorch(!isFlashOn)
        isFlashOn = !isFlashOn
        return isFlashOn
    }

    override fun start() {
        if(cameraProvider == null) return
        cameraProvider?.unbindAll()
        val previewUseCase = Preview.Builder()
            .setResolutionSelector(resolutionSelector.build())
            .build()
            .also {
                it.surfaceProvider = preview.surfaceProvider
            }
        camera = cameraProvider?.bindToLifecycle(
            activity as LifecycleOwner,
            CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                .build(),
            previewUseCase,
            imageAnalysisBuilder
        )
    }

    override fun stop() {
        if (cameraProvider == null) return
        cameraProvider?.unbindAll()
        camera = null
    }

    override fun dispose() {
        activityPluginBinding.removeRequestPermissionsResultListener(this)
        cameraExecutor?.shutdown()
        imageAnalysisBuilder?.clearAnalyzer()
        cameraProvider?.unbindAll()
        cameraProvider = null
        camera = null
        preview.removeAllViews()
    }
}
