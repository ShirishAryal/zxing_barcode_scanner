package com.shirisharyal.zxing_barcode_scanner

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.util.Size
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.camera.core.CameraSelector
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

class ScannerView(
    private val context: Context,
    private val activity: Activity,
    private val activityPluginBinding: ActivityPluginBinding,
) : PlatformView, PluginRegistry.RequestPermissionsResultListener {

    private var camera: androidx.camera.core.Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null

    companion object {
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
        private val defaultBoundSize = Size(1280, 720)
    }

    private fun allPermissionsGranted() = com.shirisharyal.zxing_barcode_scanner.ScannerView.Companion.REQUIRED_PERMISSIONS.all {
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
                com.shirisharyal.zxing_barcode_scanner.ScannerView.Companion.REQUIRED_PERMISSIONS,
                com.shirisharyal.zxing_barcode_scanner.ScannerView.Companion.REQUEST_CODE_PERMISSIONS
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
                        ResolutionSelector.Builder()
                            .setResolutionStrategy(
                                ResolutionStrategy(
                                    com.shirisharyal.zxing_barcode_scanner.ScannerView.Companion.defaultBoundSize,
                                    ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER
                                )
                            )
                            .setAspectRatioStrategy(
                                AspectRatioStrategy.RATIO_16_9_FALLBACK_AUTO_STRATEGY
                            )
                            .build()
                    )
                    .build()
                    .also {
                        it.surfaceProvider = preview.surfaceProvider
                    }

                try {
                    cameraProvider?.apply {
                        unbindAll()
                        camera = bindToLifecycle(
                            activity as LifecycleOwner,
                            CameraSelector.Builder()
                                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                                .build(),
                            previewUseCase
                        )
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }, ContextCompat.getMainExecutor(context))
        }
    }

    override fun dispose() {
        activityPluginBinding.removeRequestPermissionsResultListener(this)
        cameraProvider?.unbindAll()
        cameraProvider = null
        camera = null
        preview.removeAllViews()
    }
}