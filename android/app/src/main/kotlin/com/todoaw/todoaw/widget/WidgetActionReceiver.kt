package com.todoaw.todoaw.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodChannel

/**
 * Handles widget checkbox toggles WITHOUT opening the app (spec: app stays
 * closed). Warm path - a cached engine handles it via the `todoaw/widget`
 * channel; cold path - boot a headless FlutterEngine on the
 * `widgetActionHeadless` entrypoint, then destroy it.
 */
class WidgetActionReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "WidgetActionReceiver"
        private const val ENGINE_CACHE_ID = "todoaw_engine"
        private const val QUICK_CHANNEL = "todoaw/widget"
        private const val ACTION_CHANNEL = "todoaw/widget_action"
        private const val TIMEOUT_MS = 9_000L
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != WidgetActionsNative.ACTION_TOGGLE_TASK) return
        val uuid = intent.getStringExtra("uuid") ?: return

        val cached = FlutterEngineCache.getInstance().get(ENGINE_CACHE_ID)
        if (cached != null) {
            try {
                MethodChannel(cached.dartExecutor.binaryMessenger, QUICK_CHANNEL)
                    .invokeMethod(
                        "widgetAction",
                        mapOf(
                            "action" to WidgetActionsNative.TOGGLE_TASK,
                            "uuid" to uuid,
                        ),
                    )
            } catch (e: Exception) {
                Log.e(TAG, "warm dispatch failed", e)
            }
            return
        }

        runHeadless(context.applicationContext, uuid)
    }

    private fun runHeadless(context: Context, uuid: String) {
        val pending = goAsync()
        val handler = Handler(Looper.getMainLooper())
        var finished = false
        var engine: FlutterEngine? = null

        fun complete(success: Boolean, why: String?) {
            if (finished) return
            finished = true
            if (!success) Log.e(TAG, "headless toggle failed (uuid=$uuid): $why")
            else Log.d(TAG, "headless toggle ok (uuid=$uuid)")
            handler.post {
                try {
                    engine?.destroy()
                } catch (e: Exception) {
                    Log.e(TAG, "engine destroy failed", e)
                }
                pending.finish()
            }
        }

        try {
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(context)
            }
            loader.ensureInitializationComplete(context, null)

            val eng = FlutterEngine(context)
            engine = eng
            // Headless engines do not auto-register plugins reliably across
            // embedding versions; SharedPreferences + home_widget channels
            // are required by the toggle path (widget snapshot push).
            io.flutter.plugins.GeneratedPluginRegistrant.registerWith(eng)
            val channel = MethodChannel(eng.dartExecutor.binaryMessenger, ACTION_CHANNEL)
            channel.setMethodCallHandler { call, reply ->
                if (call.method == "ready") {
                    channel.invokeMethod(
                        "toggleTask",
                        mapOf("uuid" to uuid),
                        object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                if (result == true) {
                                    complete(true, null)
                                } else {
                                    complete(false, "toggle returned false")
                                }
                            }

                            override fun error(code: String, message: String?, details: Any?) {
                                complete(false, "$code: $message")
                            }

                            override fun notImplemented() {
                                complete(false, "notImplemented")
                            }
                        },
                    )
                    reply.success(null)
                } else {
                    reply.notImplemented()
                }
            }

            eng.dartExecutor.executeDartEntrypoint(
                DartEntrypoint(loader.findAppBundlePath(), "widgetActionHeadless"),
            )
            handler.postDelayed({ complete(false, "timeout after ${TIMEOUT_MS}ms") }, TIMEOUT_MS)
        } catch (t: Throwable) {
            complete(false, t.message ?: t.javaClass.simpleName)
        }
    }
}
