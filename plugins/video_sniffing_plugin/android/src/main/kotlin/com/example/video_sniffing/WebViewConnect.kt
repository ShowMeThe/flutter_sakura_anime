package com.example.video_sniffing

import android.content.Context
import android.os.Looper
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import java.lang.ref.SoftReference
import java.util.logging.Handler

class WebViewConnect {


    private val mHanlder by lazy { android.os.Handler(Looper.getMainLooper()) }
    private var callbacks :(String?.() -> Unit)? = null

    private var mWebView: WebView? = null
    private var sortCtx: SoftReference<Context>? = null
    private fun loadWebViewHtml() {
        Log.e("VideoSniffingPlugin", "${sortCtx}")
        if (sortCtx == null || sortCtx?.get() == null) return
        val ctx = requireNotNull(sortCtx?.get())
        if (mWebView == null) {
            mWebView = WebView(ctx)
            Log.e("VideoSniffingPlugin", "${mWebView}")
            mWebView?.apply {
                settings.javaScriptEnabled = true
                settings.cacheMode = WebSettings.LOAD_NO_CACHE
                addJavascriptInterface(VideoSniffing(), "video_sniffing")
                webViewClient = object : WebViewClient() {
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
                settings.javaScriptEnabled = true
                settings.cacheMode = WebSettings.LOAD_NO_CACHE
                addJavascriptInterface(VideoSniffing(), "video_sniffing")
                webViewClient = object : WebViewClient() {
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

    inner class VideoSniffing() {

        @JavascriptInterface
        open fun showHtml(html: String?) {
            callbacks?.invoke(html)
            onDestroy()
        }

        @JavascriptInterface
        open fun loadCustomData(html: String?) {
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

}