package com.example.video_sniffing

import android.app.Activity
import android.content.Context
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

/** VideoSniffingPlugin */
class VideoSniffingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var webViewConnect: WebViewConnect
    private lateinit var mContext: Context
    private var mWeakRefAct: WeakReference<Activity>? = null
    private val EVENT_CHANNEL = "VideoSniffingPlugin.Event"
    private var mEventSink : EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video_sniffing")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    private fun initWebConnect(){
        if (this::webViewConnect.isInitialized.not()) {
            webViewConnect = WebViewConnect(channel)
            webViewConnect.setContext(mContext)
            webViewConnect.setEventSink(mEventSink)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getRawHtml") {
            val url = call.argument<String>("baseUrl")
            Log.e("VideoSniffingPlugin", "getRawHtml ${url}")
            if (url.isNullOrBlank().not()) {
                initWebConnect()
                webViewConnect.loadUrl(mWeakRefAct?.get(), url!!) {
                    result.success(this)
                }
            }
        } else if (call.method == "getCustomData") {
            val url = call.argument<String>("baseUrl")
            val jsCode = call.argument<String>("jsCode")
            Log.e("VideoSniffingPlugin", "getCustomData ${url}")
            if (url.isNullOrBlank().not()) {
                initWebConnect()
                webViewConnect.loadCustomData(mWeakRefAct?.get(), url!!, jsCode!!) {
                    result.success(this)
                }
            }
        } else if (call.method == "getResourcesUrl") {
            val url = call.argument<String>("baseUrl")
            val resourcesName = call.argument<String>("resourcesName")
            Log.e("VideoSniffingPlugin", "getResourcesUrl ${url}")
            if (url.isNullOrBlank().not()) {
                initWebConnect()
                webViewConnect.getResourcesUrl(mWeakRefAct?.get(), url!!, resourcesName!!) {
                    result.success(this)
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        if (this::webViewConnect.isInitialized) {
            webViewConnect.onDestroy()
        }
    }

    override fun onAttachedToActivity(p0: ActivityPluginBinding) {
        Log.e("VideoSniffingPlugin", "onAttachedToActivity ${p0.activity}")
        mWeakRefAct = WeakReference(p0.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        Log.e("VideoSniffingPlugin", "onReattachedToActivityForConfigChanges ${p0.activity}")
        mWeakRefAct = WeakReference(p0.activity)
    }

    override fun onDetachedFromActivity() {
        Log.e("VideoSniffingPlugin", "onDetachedFromActivity")
        mWeakRefAct = null
    }

    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        Log.e("VideoSniffingPlugin", "onListen $p0 $p1")
        mEventSink = p1
        if(this::webViewConnect.isInitialized){
            webViewConnect.setEventSink(p1)
        }
    }

    override fun onCancel(p0: Any?) {
        Log.e("VideoSniffingPlugin", "onCancel $p0")
        mEventSink = null
        if(this::webViewConnect.isInitialized){
            webViewConnect.setEventSink(null)
        }
    }
}
