package com.todoaw.todoaw

import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val SAVE_CHANNEL = "com.todoaw.todoaw/savefile"
    private val ACTION_CHANNEL = "com.todoaw.todoaw/widget_action"
    private val BATTERY_CHANNEL = "com.todoaw.todoaw/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Battery settings channel — opens OPPO Auto-Launch or battery optimization
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openBatterySettings") {
                try {
                    val intents = listOf(
                        // OPPO Auto-Launch (modern ColorOS)
                        Intent().setClassName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
                        // OPPO Auto-Launch (older ColorOS)
                        Intent().setClassName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                        Intent().setClassName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
                        // OPPO Battery settings
                        Intent().setClassName("com.coloros.oppoguardelf", "com.coloros.powermanager.fuelgauges.PowerConsumptionActivity"),
                        // Generic battery optimization
                        Intent(android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    )
                    var opened = false
                    for (intent in intents) {
                        if (intent.resolveActivity(packageManager) != null) {
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            opened = true
                            break
                        }
                    }
                    result.success(opened)
                } catch (e: Exception) {
                    result.error("OPEN_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Save file channel (existing)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SAVE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val data = call.argument<ByteArray>("data")
                    ?: return@setMethodCallHandler result.error("NO_DATA", "data is null", null)
                val filename = call.argument<String>("filename")
                    ?: return@setMethodCallHandler result.error("NO_FILENAME", "filename is null", null)
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                try {
                    val savedPath = saveFileToDownloads(data, filename, mimeType)
                    result.success(savedPath)
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Widget action channel (new)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACTION_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPendingAction") {
                val action = intent?.getStringExtra("action") ?: ""
                val taskUuid = intent?.getStringExtra("task_uuid") ?: ""
                val noteUuid = intent?.getStringExtra("note_uuid") ?: ""
                if (action.isNotEmpty()) {
                    val data = mutableMapOf("action" to action, "taskUuid" to taskUuid)
                    if (noteUuid.isNotEmpty()) data["noteUuid"] = noteUuid
                    result.success(data)
                    intent?.removeExtra("action")
                    intent?.removeExtra("task_uuid")
                    intent?.removeExtra("note_uuid")
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun saveFileToDownloads(data: ByteArray, filename: String, mimeType: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, filename)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                ?: throw Exception("Gagal membuat entri MediaStore")
            resolver.openOutputStream(uri)?.use { it.write(data) }
                ?: throw Exception("Gagal membuka output stream")
            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
            return "Download/$filename"
        } else {
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, filename)
            FileOutputStream(file).use { it.write(data) }
            return file.absolutePath
        }
    }
}
