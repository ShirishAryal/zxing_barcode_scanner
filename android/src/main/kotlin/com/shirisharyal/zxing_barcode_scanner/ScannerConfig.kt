package com.shirisharyal.zxing_barcode_scanner

import android.util.Size
import zxingcpp.BarcodeReader


data class ScannerConfig(
    val resolution: Size = Size(1280, 720),
    val zxingOptions: ZxingOptions = ZxingOptions(),
    val ignoreEdges: Boolean = true
) {
    companion object {
        fun fromMap(map: Map<String, Any>): ScannerConfig {
            val resolution = when (map["resolution"] as? Int ?: 1) {
                0 -> Size(640, 480)
                1 -> Size(1280, 720)
                2 -> Size(1920, 1080)
                else -> Size(1280, 720)
            }
            val zxingOptionsMap = map["zxingOptions"] as? Map<String, Any> ?: emptyMap()
            val zxingOptions = ZxingOptions.fromMap(zxingOptionsMap)
            val ignoreEdges = map["ignoreEdges"] as? Boolean ?: true
            return ScannerConfig(resolution, zxingOptions)
        }
    }

    fun toMap(): Map<String, Any> {
        val resolutionValue = when (resolution) {
            Size(640, 480) -> 0
            Size(1280, 720) -> 1
            Size(1920, 1080) -> 2
            else -> 1 // Default to HD720P if the resolution doesn't match any of the specified sizes
        }
        return mapOf(
            "resolution" to resolutionValue,
            "zxingOptions" to zxingOptions.toMap(),
            "ignoreEdges" to ignoreEdges
        )
    }
}

data class ZxingOptions(
    val tryRotate: Boolean = true,
    val tryInvert: Boolean = true,
    val tryHarder: Boolean = true,
    val tryDownscale: Boolean = true,
    val maxNumberOfSymbols: Int = 1,
    val binarizer: BarcodeReader.Binarizer = BarcodeReader.Binarizer.LOCAL_AVERAGE,
    val formats: Set<BarcodeReader.Format> = setOf(BarcodeReader.Format.NONE)
) {
    companion object {
        fun fromMap(map: Map<String, Any>): ZxingOptions {
            return ZxingOptions(
                tryRotate = map["tryRotate"] as? Boolean ?: true,
                tryInvert = map["tryInvert"] as? Boolean ?: true,
                tryHarder = map["tryHarder"] as? Boolean ?: true,
                tryDownscale = map["tryDownscale"] as? Boolean ?: true,
                maxNumberOfSymbols = (map["maxNumberOfSymbols"] as? Int) ?: 1,
                binarizer = when (map["binarizer"] as? Int ?: 0) {
                    0 -> BarcodeReader.Binarizer.LOCAL_AVERAGE
                    1 -> BarcodeReader.Binarizer.GLOBAL_HISTOGRAM
                    2 -> BarcodeReader.Binarizer.FIXED_THRESHOLD
                    3 -> BarcodeReader.Binarizer.BOOL_CAST
                    else -> BarcodeReader.Binarizer.LOCAL_AVERAGE
                },
                formats = (map["formats"] as? List<*>)?.mapNotNull {
                    when (it) {
                        1 -> BarcodeReader.Format.AZTEC
                        2 -> BarcodeReader.Format.CODABAR
                        3 -> BarcodeReader.Format.CODE_39
                        4 -> BarcodeReader.Format.CODE_93
                        5 -> BarcodeReader.Format.CODE_128
                        6 -> BarcodeReader.Format.DATA_BAR
                        7 -> BarcodeReader.Format.DATA_BAR_EXPANDED
                        8 -> BarcodeReader.Format.DATA_MATRIX
                        9 -> BarcodeReader.Format.EAN_8
                        10 -> BarcodeReader.Format.EAN_13
                        11 -> BarcodeReader.Format.ITF
                        13 -> BarcodeReader.Format.PDF_417
                        14 -> BarcodeReader.Format.QR_CODE
                        15 -> BarcodeReader.Format.MICRO_QR_CODE
                        16 -> BarcodeReader.Format.RMQR_CODE
                        17 -> BarcodeReader.Format.UPC_A
                        18 -> BarcodeReader.Format.UPC_E
                        else -> null
                    }
                }?.toSet() ?: setOf(BarcodeReader.Format.NONE)
            )
        }
    }

    fun toMap(): Map<String, Any> {
        return mapOf(
            "tryRotate" to tryRotate,
            "tryInvert" to tryInvert,
            "tryHarder" to tryHarder,
            "tryDownscale" to tryDownscale,
            "maxNumberOfSymbols" to maxNumberOfSymbols,
            "binarizer" to when (binarizer) {
                BarcodeReader.Binarizer.LOCAL_AVERAGE -> 0
                BarcodeReader.Binarizer.GLOBAL_HISTOGRAM -> 1
                BarcodeReader.Binarizer.FIXED_THRESHOLD -> 2
                BarcodeReader.Binarizer.BOOL_CAST -> 3
                else -> 0
            }
        )
    }
}
