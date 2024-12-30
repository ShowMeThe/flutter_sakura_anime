package com.example.video_sniffing

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.webkit.CookieManager
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient

class CloudflareChallengesActivity : Activity() {

    companion object {
        const val EXT_URL = "EXT_URL"
    }

    private val webView by lazy { WebView(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(webView)

        val extraUrl = intent.getStringExtra(EXT_URL) ?: ""
        Log.e("VideoSniffingPlugin", "onCreate extraUrl $extraUrl")
        if(extraUrl.isBlank()){
            finish()
            return
        }

        mLastCfCookie = getCookie(extraUrl)
        webView.apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.cacheMode = WebSettings.LOAD_NO_CACHE
        }
        webView.loadUrl(extraUrl)
        webView.webViewClient = object : WebViewClient() {
            override fun shouldInterceptRequest(
                view: WebView?,
                request: WebResourceRequest?
            ): WebResourceResponse? {
                val newCookie = getCookie(extraUrl)
                if(newCookie != mLastCfCookie){
                    Log.e("VideoSniffingPlugin", "newCookie")
                    setResult(RESULT_OK)
                    finish()
                }
                return super.shouldInterceptRequest(view, request)
            }

            override fun onPageFinished(view: WebView, url: String?) {
                super.onPageFinished(view, url)
            }
        }
    }

    private val cookie by lazy { CookieManager.getInstance() }
    private var mLastCfCookie = ""
    private fun getCookie(extraUrl: String): String {
        val cookies = cookie.getCookie(extraUrl)?.split(";")
        var cookieValue = ""
        cookies?.forEach loop@{ cookie ->
            val pair = cookie.split("=")
            val key = pair[0]
            val value = pair[1]
            if (key == "cf_clearance" && value.isNotBlank()) {
                cookieValue = value
                return@loop
            }
        }
        return cookieValue
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.e("VideoSniffingPlugin", "CloudflareChallengesActivity onDestroy")
        webView.destroy()
    }
}