package com.todoaw.todoaw.widget

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import com.todoaw.todoaw.R
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class QuickInputActivity : Activity() {
    companion object {
        const val ACTION_MODE = "com.todoaw.todoaw.widget.QUICK_INPUT"
        const val EXTRA_MODE = "mode"
        const val MODE_TASK = "task"
        const val MODE_NOTE = "note"
        const val CHANNEL = "todoaw/widget"
        const val CACHE_ID = "todoaw_engine"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        window.setDimAmount(0.55f)
        setContentView(R.layout.activity_quick_input)

        val mode = intent.getStringExtra(EXTRA_MODE) ?: MODE_TASK
        val card = findViewById<LinearLayout>(R.id.widget_quick_input_card)
        val titleView = findViewById<TextView>(R.id.widget_quick_input_title)
        val field = findViewById<EditText>(R.id.widget_quick_input_field)
        val timeField = findViewById<EditText>(R.id.widget_quick_input_time)
        val error = findViewById<TextView>(R.id.widget_quick_input_error)
        val save = findViewById<Button>(R.id.widget_quick_input_save)
        val cancel = findViewById<Button>(R.id.widget_quick_input_cancel)

        try {
            val p = WidgetTheme.palette(HomeWidgetPlugin.getData(this))
            card.setBackgroundColor(p.card)
            titleView.setTextColor(p.text)
            field.setTextColor(p.text)
            field.setHintTextColor(p.muted)
            timeField.setTextColor(p.text)
            timeField.setHintTextColor(p.muted)
            save.setBackgroundColor(p.accent)
        } catch (_: Exception) {
        }

        if (mode == MODE_TASK) {
            titleView.text = "Tugas baru"
            field.hint = "Tambah tugas baru..."
            timeField.visibility = View.VISIBLE
            timeField.hint = "HH:mm (opsional)"
        } else {
            titleView.text = "Catatan cepat"
            field.hint = "Tulis catatan cepat..."
            timeField.visibility = View.GONE
        }

        cancel.setOnClickListener { finish() }
        save.setOnClickListener {
            val title = field.text.toString().trim()
            if (title.isEmpty()) {
                error.text = "Judul tidak boleh kosong"
                error.visibility = View.VISIBLE
                return@setOnClickListener
            }
            val time = timeField.text.toString().trim()
            saveViaFlutter(mode, title, time.ifBlank { null }) { ok, errMsg ->
                runOnUiThread {
                    if (ok) {
                        finish()
                    } else {
                        error.text = errMsg ?: "Gagal menyimpan, coba lagi"
                        error.visibility = View.VISIBLE
                    }
                }
            }
        }
    }

    private fun saveViaFlutter(
        mode: String,
        title: String,
        time: String?,
        callback: (Boolean, String?) -> Unit,
    ) {
        val engine = FlutterEngineCache.getInstance().get(CACHE_ID)
        if (engine == null) {
            // Cold path: stash payload, launch main activity so Dart can drain.
            try {
                val prefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
                prefs.edit()
                    .putString("pending_quick_mode", mode)
                    .putString("pending_quick_title", title)
                    .putString("pending_quick_time", time ?: "")
                    .apply()
            } catch (_: Exception) {
            }
            val launch = packageManager.getLaunchIntentForPackage(packageName)
            if (launch != null) {
                launch.putExtra("pending_quick_mode", mode)
                launch.putExtra("pending_quick_title", title)
                launch.putExtra("pending_quick_time", time ?: "")
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launch)
            }
            callback(true, null)
            finish()
            return
        }
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        val args = mutableMapOf<String, Any?>(
            "mode" to mode,
            "title" to title,
        )
        if (time != null) args["time"] = time
        channel.invokeMethod("saveQuick", args, object : MethodChannel.Result {
            override fun success(result: Any?) {
                val map = result as? Map<*, *>
                if (map?.get("ok") == true) callback(true, null)
                else callback(false, map?.get("error") as? String)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(false, errorMessage)
            }

            override fun notImplemented() {
                callback(false, "Channel tidak tersedia")
            }
        })
    }
}
