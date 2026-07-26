package com.todoaw.todoaw

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

private const val BASE = 30000
private const val HEADER_CODE = BASE + 0
private const val STREAK_CODE = BASE + 1
private const val ADD_TASK_CODE = BASE + 20
private const val PROGRESS_CODE = BASE + 30
private const val TASK_BASE = BASE + 10

class TodoawListWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val widgetBg = parseColor(widgetData.getString("widgetBg", "FF0EA5E9"))
        val accentColor = parseColor(widgetData.getString("accentColor", "FF0EA5E9"))
        val textColor = parseColor(widgetData.getString("textColor", "FFFFFFFF"))

        val pendingCount = widgetData.getString("pendingCount", "0")?.toIntOrNull() ?: 0
        val completedCount = widgetData.getString("completedCount", "0")?.toIntOrNull() ?: 0
        val totalCount = widgetData.getString("totalCount", "0")?.toIntOrNull() ?: 0
        val progress = widgetData.getString("progress", "0")?.toIntOrNull() ?: 0
        val streak = widgetData.getString("streak", "0")?.toIntOrNull() ?: 0
        val timeSticker = widgetData.getString("timeSticker", "") ?: ""
        val manualSticker = widgetData.getString("manualSticker", "") ?: ""
        val customStickerText = widgetData.getString("customStickerText", "") ?: ""
        val streakMode = widgetData.getString("streakMode", "") ?: ""
        val celebration = widgetData.getString("celebration", "") ?: ""

        val taskListJson = widgetData.getString("taskList", "[]") ?: "[]"
        val taskUuidsJson = widgetData.getString("taskUuids", "[]") ?: "[]"
        val taskList = mutableListOf<String>()
        val taskUuids = mutableListOf<String>()
        try {
            val arr = JSONArray(taskListJson)
            for (i in 0 until arr.length()) taskList.add(arr.getString(i))
            val uuidArr = JSONArray(taskUuidsJson)
            for (i in 0 until uuidArr.length()) taskUuids.add(uuidArr.getString(i))
        } catch (_: Exception) {}

        val views = RemoteViews(context.packageName, R.layout.widget_list)
        views.setInt(R.id.widget_root, "setBackgroundColor", widgetBg)

        // confetti overlay
        if (celebration == "confetti") {
            views.setViewVisibility(R.id.iv_confetti_overlay, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.iv_confetti_overlay, View.GONE)
        }

        views.setTextViewText(R.id.widget_list_title, "Tugas Tertunda")
        views.setTextColor(R.id.widget_list_title, textColor)
        views.setOnClickPendingIntent(R.id.widget_list_title, createIntent(context, "open_home", HEADER_CODE))

        views.setTextViewText(R.id.widget_done_count, "$completedCount/$totalCount")
        views.setTextColor(R.id.widget_done_count, textColor)

        if (streak > 0) {
            views.setViewVisibility(R.id.widget_streak_icon, View.VISIBLE)
            views.setViewVisibility(R.id.widget_streak, View.VISIBLE)
            views.setTextViewText(R.id.widget_streak, streak.toString())
            views.setTextColor(R.id.widget_streak, textColor)
            views.setOnClickPendingIntent(R.id.widget_streak_icon, createIntent(context, "open_stats", STREAK_CODE))
            views.setOnClickPendingIntent(R.id.widget_streak, createIntent(context, "open_stats", STREAK_CODE + 1))
        } else {
            views.setViewVisibility(R.id.widget_streak_icon, View.GONE)
            views.setViewVisibility(R.id.widget_streak, View.GONE)
        }

        // fire_big
        if (streakMode == "fire" && streak >= 5) {
            views.setViewVisibility(R.id.iv_fire_big, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.iv_fire_big, View.GONE)
        }

        // time sticker
        val timeRes = getTimeStickerDrawable(timeSticker)
        if (timeRes != 0) {
            views.setImageViewResource(R.id.iv_time_sticker, timeRes)
            views.setViewVisibility(R.id.iv_time_sticker, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.iv_time_sticker, View.GONE)
        }

        // manual sticker
        val manualRes = getStickerDrawable(manualSticker)
        if (manualSticker == "custom" && customStickerText.isNotEmpty()) {
            views.setTextViewText(R.id.widget_sticker_text, customStickerText)
            views.setViewVisibility(R.id.widget_sticker_text, View.VISIBLE)
            views.setViewVisibility(R.id.iv_manual_sticker, View.GONE)
        } else if (manualRes != 0) {
            views.setImageViewResource(R.id.iv_manual_sticker, manualRes)
            views.setViewVisibility(R.id.iv_manual_sticker, View.VISIBLE)
            views.setViewVisibility(R.id.widget_sticker_text, View.GONE)
        } else {
            views.setViewVisibility(R.id.iv_manual_sticker, View.GONE)
            views.setViewVisibility(R.id.widget_sticker_text, View.GONE)
        }

        views.setInt(R.id.widget_progress, "setProgress", progress)
        views.setOnClickPendingIntent(R.id.widget_progress, createIntent(context, "open_calendar", PROGRESS_CODE))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                views.setColorStateList(
                    R.id.widget_progress, "setProgressTintList",
                    android.content.res.ColorStateList.valueOf(accentColor)
                )
            } catch (_: Exception) {}
        }

        if (taskList.isEmpty()) {
            views.setViewVisibility(R.id.widget_task_container, View.GONE)
            views.setViewVisibility(R.id.widget_list_empty, View.VISIBLE)
            views.setTextColor(R.id.widget_list_empty, dimColor(textColor, 0.6f))
        } else {
            views.setViewVisibility(R.id.widget_task_container, View.VISIBLE)
            views.setViewVisibility(R.id.widget_list_empty, View.GONE)

            val taskIds = listOf(
                R.id.widget_task_1, R.id.widget_task_2, R.id.widget_task_3,
                R.id.widget_task_4, R.id.widget_task_5
            )

            for (i in taskIds.indices) {
                if (i < taskList.size) {
                    views.setTextViewText(taskIds[i], "\u2022 ${taskList[i]}")
                    views.setTextColor(taskIds[i], textColor)
                    views.setViewVisibility(taskIds[i], View.VISIBLE)
                    val uuid = if (i < taskUuids.size) taskUuids[i] else null
                    views.setOnClickPendingIntent(taskIds[i], createIntent(context, "edit_task", TASK_BASE + i, uuid))
                } else {
                    views.setViewVisibility(taskIds[i], View.GONE)
                }
            }
        }

        // remaining + add button
        if (pendingCount > 0) {
            views.setViewVisibility(R.id.widget_remaining_icon, View.VISIBLE)
            views.setViewVisibility(R.id.widget_remaining_text, View.VISIBLE)
            views.setTextViewText(R.id.widget_remaining_text, "$pendingCount tersisa")
            views.setTextColor(R.id.widget_remaining_text, dimColor(textColor, 0.5f))
        } else {
            views.setViewVisibility(R.id.widget_remaining_icon, View.GONE)
            views.setViewVisibility(R.id.widget_remaining_text, View.GONE)
        }

        views.setOnClickPendingIntent(R.id.btn_add_task, createIntent(context, "new_task", ADD_TASK_CODE))

        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun createIntent(context: Context, action: String, code: Int, taskUuid: String? = null): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("action", action)
            if (taskUuid != null) putExtra("task_uuid", taskUuid)
        }
        return PendingIntent.getActivity(
            context, code, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun getStickerDrawable(name: String): Int = when (name) {
        "sparkle" -> R.drawable.ic_sticker_sparkle
        "sun" -> R.drawable.ic_sticker_sun
        "moon" -> R.drawable.ic_sticker_moon
        "flower" -> R.drawable.ic_sticker_flower
        "star" -> R.drawable.ic_sticker_star
        "heart" -> R.drawable.ic_sticker_heart
        "smile" -> R.drawable.ic_sticker_smile
        "lightning" -> R.drawable.ic_sticker_lightning
        "music" -> R.drawable.ic_sticker_music
        "party" -> R.drawable.ic_sticker_party
        else -> 0
    }

    private fun getTimeStickerDrawable(name: String): Int = when (name) {
        "sun" -> R.drawable.ic_sticker_sun
        "moon" -> R.drawable.ic_sticker_moon
        "sparkle" -> R.drawable.ic_sticker_sparkle
        else -> 0
    }

    private fun parseColor(hex: String?): Int {
        if (hex == null) return 0xFF0EA5E9.toInt()
        return try {
            val clean = hex.replace("#", "").replace("0x", "")
            val full = if (clean.length == 6) "FF$clean" else clean
            java.lang.Long.parseLong(full, 16).toInt()
        } catch (_: Exception) {
            0xFF0EA5E9.toInt()
        }
    }

    private fun dimColor(color: Int, factor: Float): Int {
        return Color.argb(
            (Color.alpha(color) * factor).toInt(),
            Color.red(color),
            Color.green(color),
            Color.blue(color)
        )
    }
}
