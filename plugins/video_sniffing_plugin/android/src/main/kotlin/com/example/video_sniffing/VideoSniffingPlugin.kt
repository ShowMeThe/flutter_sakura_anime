package com.example.video_sniffing

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VideoSniffingPlugin */
class VideoSniffingPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var webViewConnect: WebViewConnect
    private lateinit var mContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video_sniffing")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getRawHtml") {
            val url = call.argument<String>("baseUrl")
            Log.e("VideoSniffingPlugin","${url}")
            if(url.isNullOrBlank().not()){
                if (this::webViewConnect.isInitialized.not()) {
                    webViewConnect = WebViewConnect()
                    webViewConnect.setContext(mContext)
                }
                webViewConnect.loadUrl(url!!){
                    result.success(this)
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        if (this::webViewConnect.isInitialized) {
            webViewConnect.onDestroy()
        }
    }
}
