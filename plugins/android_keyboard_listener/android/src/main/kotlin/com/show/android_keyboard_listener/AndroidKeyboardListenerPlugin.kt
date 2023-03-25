package com.show.android_keyboard_listener

import android.graphics.Rect
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


/** AndroidKeyboardListenerPlugin */
class AndroidKeyboardListenerPlugin : FlutterPlugin, ActivityAware, EventChannel.StreamHandler,
    ViewTreeObserver.OnGlobalLayoutListener {

    private var eventSink: EventSink? = null
    private var mainView: View? = null
    private var isVisible = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel =
            EventChannel(flutterPluginBinding.binaryMessenger, "android_keyboard_listener")
        channel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        detachToAct()
    }

    override fun onAttachedToActivity(p0: ActivityPluginBinding) {
        attachToAct(p0)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        attachToAct(p0)
    }

    override fun onDetachedFromActivity() {
        detachToAct()
    }

    override fun onListen(p0: Any?, p1: EventSink?) {
        eventSink = p1
    }

    override fun onCancel(p0: Any?) {
        eventSink = null
    }

    override fun onGlobalLayout() {
        if (mainView != null) {
            val rect = Rect()
            val rootView = requireNotNull(mainView)
            rootView.getWindowVisibleDisplayFrame(rect)

            val newState =  (rect.height()  / rootView.rootView.height.toDouble()) < 0.85

            if (newState != isVisible) {
                isVisible = newState
                if (eventSink != null) {
                    eventSink?.success(if (isVisible) 1 else 0)
                }
            }
        }
    }

    private fun attachToAct(binding: ActivityPluginBinding) {
        mainView = binding.activity.findViewById(android.R.id.content)
        mainView?.viewTreeObserver?.addOnGlobalLayoutListener(this)
    }

    private fun detachToAct() {
        mainView?.viewTreeObserver?.removeOnGlobalLayoutListener(this)
        mainView = null
    }

}
