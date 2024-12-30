package com.example.video_sniffing

import android.app.Activity
import android.app.NotificationChannel
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Looper
import android.util.Log
import android.webkit.*
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.SoftReference
import java.util.logging.Handler

class WebViewConnect(private val channel:MethodChannel){


    private val cloudflareChallenges = "challenges.cloudflare.com"
    private val mHanlder by lazy { android.os.Handler(Looper.getMainLooper()) }
    private var callbacks: (String?.() -> Unit)? = null

    private var mWebView: WebView? = null
    private var sortCtx: SoftReference<Context>? = null
    private var isStartChecking = false
    private var mEventSink : EventChannel.EventSink? = null
    fun setEventSink(sink: EventChannel.EventSink?){
        mEventSink = sink
    }

    private fun WebView.baseSetting() {
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.cacheMode = WebSettings.LOAD_NO_CACHE
        webChromeClient = object : WebChromeClient() {}
        addJavascriptInterface(VideoSniffing(), "video_sniffing")
    }


    private fun loadWebViewHtml(activity: Activity?, baseUrl: String) {
        isStartChecking = false
        Log.e("VideoSniffingPlugin", "${sortCtx}")
        if (sortCtx == null || sortCtx?.get() == null) return
        val ctx = requireNotNull(sortCtx?.get())
        if (mWebView == null) {
            mWebView = WebView(ctx)
            Log.e("VideoSniffingPlugin", "${mWebView}")
            mWebView?.apply {
                baseSetting()
                webViewClient = object : WebViewClient() {
                    override fun onReceivedError(
                        view: WebView?,
                        request: WebResourceRequest?,
                        error: WebResourceError?
                    ) {
                        super.onReceivedError(view, request, error)
                        Log.e("VideoSniffingPlugin", "error = ${error?.description}")
                    }

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        Log.e("VideoSniffingPlugin", "shouldInterceptRequest ${request?.url}")
                        checkHasCloudChallenge(activity, request?.url, baseUrl)
                        return super.shouldInterceptRequest(view, request)
                    }

                    override fun onPageFinished(view: WebView, url: String?) {
                        super.onPageFinished(view, url)
                        Log.e("VideoSniffingPlugin", "finish")
                        view
                            .loadUrl("javascript:window.video_sniffing.showHtml(document.getElementsByTagName('html')[0].innerHTML);")
                    }
                }
            }
        }
    }

    private fun loadWebViewCustomData(activity: Activity?, jsCode: String, baseUrl: String) {
        isStartChecking = false
        Log.e("VideoSniffingPlugin", "${sortCtx}")
        if (sortCtx == null || sortCtx?.get() == null) return
        val ctx = requireNotNull(sortCtx?.get())
        if (mWebView == null) {
            mWebView = WebView(ctx)
            Log.e("VideoSniffingPlugin", "${mWebView}")
            mWebView?.apply {
                baseSetting()
                webViewClient = object : WebViewClient() {
                    override fun onReceivedError(
                        view: WebView?,
                        request: WebResourceRequest?,
                        error: WebResourceError?
                    ) {
                        super.onReceivedError(view, request, error)
                        Log.e("VideoSniffingPlugin", "error = ${error?.description}")
                    }

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        Log.e("VideoSniffingPlugin", "shouldInterceptRequest ${request?.url}")
                        checkHasCloudChallenge(activity, request?.url, baseUrl)
                        return super.shouldInterceptRequest(view, request)
                    }

                    override fun onPageFinished(view: WebView, url: String?) {
                        super.onPageFinished(view, url)
                        Log.e("VideoSniffingPlugin", "finish")
                        view
                            .loadUrl("javascript:window.video_sniffing.loadCustomData(${jsCode});")
                    }
                }
            }
        }
    }


    private fun checkHasCloudChallenge(activity: Activity?, url: Uri?, baseUrl: String) {
        if (url?.host?.equals(cloudflareChallenges) == true && !isStartChecking) {
            activity?.apply {
                Log.e("VideoSniffingPlugin", "startActivity $this")
                isStartChecking = true
                val intent = Intent(this, CloudflareChallengesActivity::class.java).apply {
                    putExtra(CloudflareChallengesActivity.EXT_URL, baseUrl)
                    //addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                this.runOnUiThread {
                    if(this is FragmentActivity){
                        startForResult(intent){
                            sendCloudFlareResult(it.resultCode == Activity.RESULT_OK)
                        }
                    }else{
                        startActivity(intent)
                    }
                }
            }
        }
    }

    private fun getResourcesUrl(activity: Activity?, resourcesName: String, baseUrl: String) {
        isStartChecking = false
        Log.e("VideoSniffingPlugin", "${sortCtx}")
        if (sortCtx == null || sortCtx?.get() == null) return
        val ctx = requireNotNull(sortCtx?.get())
        if (mWebView == null) {
            mWebView = WebView(ctx)
            Log.e("VideoSniffingPlugin", "${mWebView}")
            var hasFoundResource = false
            mWebView?.apply {
                baseSetting()
                webViewClient = object : WebViewClient() {
                    override fun onReceivedError(
                        view: WebView?,
                        request: WebResourceRequest?,
                        error: WebResourceError?
                    ) {
                        super.onReceivedError(view, request, error)
                        Log.e("VideoSniffingPlugin", "error = ${error?.description}")
                    }

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        Log.e("VideoSniffingPlugin", "request = ${request?.url}")
                        checkHasCloudChallenge(activity, request?.url, baseUrl)
                        var resourcesUrl = request?.url?.toString()
                        if (resourcesUrl != null && resourcesUrl.contains(resourcesName)) {
                            hasFoundResource = true
                            callbacks?.invoke(resourcesUrl)
                            onDestroy()
                        }
                        return super.shouldInterceptRequest(view, request)
                    }

                    override fun onPageFinished(view: WebView, url: String?) {
                        super.onPageFinished(view, url)
                        onDestroy()
                        if (!hasFoundResource) {
                            callbacks?.invoke("")
                        }
                        Log.e("VideoSniffingPlugin", "finish")
                    }
                }
            }
        }
    }

    inner class VideoSniffing() {

        @JavascriptInterface
        open fun showHtml(html: String?) {
            Log.e("VideoSniffingPlugin", "showHtml = ${html}")
            callbacks?.invoke(html)
            onDestroy()
        }

        @JavascriptInterface
        open fun loadCustomData(html: String?) {
            Log.e("VideoSniffingPlugin", "showHtml = ${html}")
            callbacks?.invoke(html)
            onDestroy()
        }

    }

    fun setContext(context: Context) {
        sortCtx = SoftReference(context)
    }

    fun onDestroy() {
        mHanlder.post {
            mWebView?.destroy()
            mWebView = null
        }
    }

    fun loadUrl(activity: Activity?, baseUrl: String, callback: String?.() -> Unit) {
        loadWebViewHtml(activity, baseUrl)
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }

    fun loadCustomData(
        activity: Activity?,
        baseUrl: String,
        jsCode: String,
        callback: String?.() -> Unit
    ) {
        loadWebViewCustomData(activity, jsCode, baseUrl)
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }

    fun getResourcesUrl(
        activity: Activity?,
        baseUrl: String,
        resourcesName: String,
        callback: String?.() -> Unit
    ) {
        getResourcesUrl(activity, resourcesName, baseUrl)
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }


    private fun sendCloudFlareResult(result:Boolean){
        mEventSink?.success(result)
    }
}