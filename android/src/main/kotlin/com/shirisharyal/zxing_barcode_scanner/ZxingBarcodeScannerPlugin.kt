package com.shirisharyal.zxing_barcode_scanner

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ZxingBarcodeScannerPlugin: FlutterPlugin, ActivityAware{
  private var  flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null
  private val viewType = "com.shirisharyal.zxing_barcode_scanner"

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding = binding
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    flutterPluginBinding!!.platformViewRegistry.registerViewFactory(viewType, ZxingBarcodeScannerViewFactory(
      binding.activity,
      binding,
      flutterPluginBinding = flutterPluginBinding!!,
    ))
  }

  override fun onDetachedFromActivityForConfigChanges() {
    flutterPluginBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    flutterPluginBinding!!.platformViewRegistry.registerViewFactory(viewType, ZxingBarcodeScannerViewFactory(
      binding.activity,
      binding,
      flutterPluginBinding = flutterPluginBinding!!,
    ))
  }

  override fun onDetachedFromActivity() {
    flutterPluginBinding = null
  }
}

class ZxingBarcodeScannerViewFactory(
  private val activity: Activity,
  private val activityPluginBinding: ActivityPluginBinding,
  private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
): PlatformViewFactory(StandardMessageCodec.INSTANCE){
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    return ScannerView(
      context =context,
      activity = activity,
      activityPluginBinding = activityPluginBinding,
      flutterPluginBinding = flutterPluginBinding,
      scannerConfig =  ScannerConfig.fromMap(args as Map<String, Any>)
    )
  }
}
