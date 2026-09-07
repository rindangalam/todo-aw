package com.todoaw.todoaw

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CompactWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_compact_v2)

            val accentColor = WidgetUtils.parseColor(widgetData.getString("accentColor", null), 0xFF3B82F6)
            val textColor = WidgetUtils.parseColor(widgetData.getString("textColor", null), 0xFFFFFFFF)
            val completedCount = widgetData.getString("completedCount", null)?.toIntOrNull() ?: 0
            val totalCount = widgetData.getString("totalCount", null)?.toIntOrNull() ?: 0
            val nextTaskTitle = widgetData.getString("nextTaskTitle", null) ?: ""
            val nextTaskTime = widgetData.getString("nextTaskTime", null) ?: ""

            // Logo
            views.setTextViewText(R.id.widget_compact_logo, "todoaw")
            views.setTextColor(R.id.widget_compact_logo, textColor)

            // Progress indicator text
            views.setTextViewText(R.id.widget_compact_progress, "$completedCount/$totalCount")
            views.setTextColor(R.id.widget_compact_progress, accentColor)

            // Next task
            if (nextTaskTitle.isNotEmpty()) {
                views.setTextViewText(R.id.widget_compact_next_title, nextTaskTitle)
                views.setTextColor(R.id.widget_compact_next_title, textColor)
                views.setTextViewText(R.id.widget_compact_next_time, nextTaskTime)
                views.setTextColor(R.id.widget_compact_next_time, WidgetUtils.parseColor(null, 0xFF94A3B8))
            }

            // Click entire widget → open home
            val homeIntent = Intent(context, MainActivity::class.java).apply {
                action = "open_home"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val homePending = PendingIntent.getActivity(
                context, 50000, homeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_compact_root, homePending)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
