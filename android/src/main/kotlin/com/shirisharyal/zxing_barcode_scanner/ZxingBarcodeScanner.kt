// Autogenerated from Pigeon (v22.7.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")


import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  return if (exception is ZxingBarcodeScannerError) {
    listOf(
      exception.code,
      exception.message,
      exception.details
    )
  } else {
    listOf(
      exception.javaClass.simpleName,
      exception.toString(),
      "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
    )
  }
}

private fun createConnectionError(channelName: String): ZxingBarcodeScannerError {
  return ZxingBarcodeScannerError("channel-error",  "Unable to establish connection on channel: '$channelName'.", "")}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class ZxingBarcodeScannerError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class BarcodeResult (
  val text: String? = null,
  val format: String? = null
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): BarcodeResult {
      val text = pigeonVar_list[0] as String?
      val format = pigeonVar_list[1] as String?
      return BarcodeResult(text, format)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      text,
      format,
    )
  }
}
private open class ZxingBarcodeScannerPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          BarcodeResult.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is BarcodeResult -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
class ZxingBarcodeScannerFlutterApi(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") {
  companion object {
    /** The codec used by ZxingBarcodeScannerFlutterApi. */
    val codec: MessageCodec<Any?> by lazy {
      ZxingBarcodeScannerPigeonCodec()
    }
  }
  fun onScanSuccess(resultsArg: List<BarcodeResult>, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerFlutterApi.onScanSuccess$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(resultsArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(ZxingBarcodeScannerError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
}
/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface ZxingBarcodeScannerController {
  fun toggleFlash(): Boolean
  fun start()
  fun stop()
  fun dispose()

  companion object {
    /** The codec used by ZxingBarcodeScannerController. */
    val codec: MessageCodec<Any?> by lazy {
      ZxingBarcodeScannerPigeonCodec()
    }
    /** Sets up an instance of `ZxingBarcodeScannerController` to handle messages through the `binaryMessenger`. */
    @JvmOverloads
    fun setUp(binaryMessenger: BinaryMessenger, api: ZxingBarcodeScannerController?, messageChannelSuffix: String = "") {
      val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.toggleFlash$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              listOf(api.toggleFlash())
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.start$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.start()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.stop$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.stop()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.zxing_barcode_scanner.ZxingBarcodeScannerController.dispose$separatedMessageChannelSuffix", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              api.dispose()
              listOf(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}
