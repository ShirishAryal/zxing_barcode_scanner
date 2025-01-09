package com.shirisharyal.zxing_barcode_scanner

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.util.Log
import android.util.Size
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import android.widget.Toast
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
) : PlatformView, PluginRegistry.RequestPermissionsResultListener {

    private var camera: androidx.camera.core.Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysisBuilder: ImageAnalysis? = null
    private var  barcodeReader: BarcodeReader? = null
    private var cameraExecutor: ExecutorService? = null


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

    private val container = FrameLayout(context).apply {
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
    }

    @SuppressLint("SetTextI18n")
    private val messageView = TextView(context).apply {
        text = "Couldn't initialize camera"
        gravity = Gravity.CENTER
        textSize = 20f
    }

    private val preview = PreviewView(context).apply {
        scaleType = PreviewView.ScaleType.FIT_CENTER
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    }

    override fun getView(): View = container

    init {
        activityPluginBinding.addRequestPermissionsResultListener(this)
        container.setBackgroundColor(Color.WHITE)
        if(allPermissionsGranted()){
            container.addView(preview)
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

        if (requestCode == com.shirisharyal.zxing_barcode_scanner.ScannerView.Companion.REQUEST_CODE_PERMISSIONS) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted - show camera
                container.removeView(messageView)
                if (preview.parent == null) {
                    container.addView(preview)
                }
                startCamera()
            } else {
                // Permission denied - show error message
                container.removeView(preview)
                if (messageView.parent == null) {
                    container.addView(messageView)
                }
            }
            return true
        }
        return false
    }


    private fun startCamera() {
        ProcessCameraProvider.getInstance(context).apply {
            addListener({
                cameraProvider = get()
                cameraProvider?.unbindAll()

                val previewUseCase = Preview.Builder()
                    .setResolutionSelector(
                        resolutionSelector.build()
                    )
                    .build()
                    .also {
                        it.surfaceProvider = preview.surfaceProvider
                    }

                setupBarcodeReader()
                setupImageAnalysis()
                cameraExecutor = Executors.newSingleThreadExecutor()
                imageAnalysisBuilder?.setAnalyzer(cameraExecutor!!) {
                    scanBarcodes(it)
                }

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
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }, ContextCompat.getMainExecutor(context))
        }

    }

    private fun setupImageAnalysis() {
        imageAnalysisBuilder = ImageAnalysis.Builder()
            .setResolutionSelector(resolutionSelector.build())
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setImageQueueDepth(1)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
            .build()
    }

    private fun setupBarcodeReader() {
      val options = BarcodeReader.Options().apply {
            formats = setOf(BarcodeReader.Format.QR_CODE)
            tryRotate = true
            tryInvert = true
            tryHarder = true
            tryDownscale = true
            maxNumberOfSymbols = 1
            binarizer = BarcodeReader.Binarizer.LOCAL_AVERAGE
        }
      barcodeReader = BarcodeReader(options)
    }

    private fun scanBarcodes(imageProxy: ImageProxy) {
        val startTime = System.currentTimeMillis()
        val results = barcodeReader?.read(imageProxy)
        imageProxy.close()
        if (!results.isNullOrEmpty()) {
            val duration = System.currentTimeMillis() - startTime
            Log.d(TAG, "Results: $results, took ${duration}ms to scan")
        }
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
