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

class TodoawCompactWidget : HomeWidgetProvider() {

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

        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val views = RemoteViews(context.packageName, R.layout.widget_compact)
        views.setInt(R.id.widget_root, "setBackgroundColor", widgetBg)

        views.setTextViewText(R.id.widget_title, "Todoaw")
        views.setTextColor(R.id.widget_title, textColor)
        views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

        if (streak > 0) {
            views.setViewVisibility(R.id.widget_streak_icon, View.VISIBLE)
            views.setViewVisibility(R.id.widget_streak, View.VISIBLE)
            views.setTextViewText(R.id.widget_streak, streak.toString())
            views.setTextColor(R.id.widget_streak, textColor)
        } else {
            views.setViewVisibility(R.id.widget_streak_icon, View.GONE)
            views.setViewVisibility(R.id.widget_streak, View.GONE)
        }

        views.setInt(R.id.widget_progress, "setProgress", progress)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                views.setColorStateList(
                    R.id.widget_progress, "setProgressTintList",
                    android.content.res.ColorStateList.valueOf(accentColor)
                )
            } catch (_: Exception) {}
        }

        val summaryText = if (completedCount > 0) {
            "$completedCount/$totalCount selesai"
        } else {
            "$pendingCount tertunda"
        }
        views.setTextViewText(R.id.widget_summary, summaryText)
        views.setTextColor(R.id.widget_summary, dimColor(textColor, 0.6f))
        views.setOnClickPendingIntent(R.id.widget_summary, pendingIntent)

        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
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
