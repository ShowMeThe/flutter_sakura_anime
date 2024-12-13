package com.example.video_sniffing

import android.content.Context
import android.os.Looper
import android.util.Log
import android.webkit.*
import java.lang.ref.SoftReference
import java.util.logging.Handler

class WebViewConnect {


    private val mHanlder by lazy { android.os.Handler(Looper.getMainLooper()) }
    private var callbacks :(String?.() -> Unit)? = null

    private var mWebView: WebView? = null
    private var sortCtx: SoftReference<Context>? = null

    private fun WebView.baseSetting(){
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.cacheMode = WebSettings.LOAD_NO_CACHE
        webChromeClient = object : WebChromeClient() {}
        addJavascriptInterface(VideoSniffing(), "video_sniffing")
    }


    private fun loadWebViewHtml() {
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

    private fun loadWebViewCustomData(jsCode:String) {
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

    private fun getResourcesUrl(resourcesName:String) {
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
                        var resourcesUrl = request?.url?.toString()
                        if(resourcesUrl != null && resourcesUrl.contains(resourcesName)){
                            hasFoundResource = true
                            callbacks?.invoke(resourcesUrl)
                            onDestroy()
                        }
                        return super.shouldInterceptRequest(view, request)
                    }

                    override fun onPageFinished(view: WebView, url: String?) {
                        super.onPageFinished(view, url)
                        onDestroy()
                        if(!hasFoundResource){
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

    fun loadUrl(baseUrl: String, callback: String?.() -> Unit) {
        loadWebViewHtml()
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }

    fun loadCustomData(baseUrl: String,jsCode:String, callback: String?.() -> Unit) {
        loadWebViewCustomData(jsCode)
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }

    fun getResourcesUrl(baseUrl: String,resourcesName:String, callback: String?.() -> Unit) {
        getResourcesUrl(resourcesName)
        mWebView?.loadUrl(baseUrl)
        callbacks = callback
    }

}