package com.example.video_sniffing

import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultCallback
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import java.util.concurrent.atomic.AtomicInteger

private val nextLocalRequestCode = AtomicInteger()
fun FragmentActivity.startForResult(
    input: Intent,
    callback: ActivityResultCallback<ActivityResult>
) {
    val key = "activity_rq_for_result#${nextLocalRequestCode.getAndIncrement()}"
    val registry = (this as ComponentActivity).activityResultRegistry
    var launcher: ActivityResultLauncher<Intent>? = null
    val observer = object : LifecycleEventObserver {
        override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
            if (event == Lifecycle.Event.ON_DESTROY) {
                launcher?.unregister()
                lifecycle.removeObserver(this)
            }
        }
    }
    lifecycle.addObserver(observer)
    launcher = registry.register(key, ActivityResultContracts.StartActivityForResult()) {
        launcher?.unregister()
        lifecycle.removeObserver(observer)
        callback.onActivityResult(it)
    }
    try {
        launcher.launch(input)
    } catch (e: Throwable) {
        e.printStackTrace()
    }
}