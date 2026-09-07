package com.todoaw.todoaw

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class QuickAddWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add)

            val textColor = WidgetUtils.parseColor(widgetData.getString("textColor", null), 0xFFFFFFFF)

            // Logo
            views.setTextViewText(R.id.widget_quick_add_logo, "todoaw")
            views.setTextColor(R.id.widget_quick_add_logo, textColor)

            // Click logo → open home
            val homeIntent = Intent(context, MainActivity::class.java).apply {
                action = "open_home"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val homePending = PendingIntent.getActivity(
                context, 60000, homeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quick_add_logo, homePending)

            // Click "+" → new task
            val newTaskIntent = Intent(context, MainActivity::class.java).apply {
                action = "new_task"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val newTaskPending = PendingIntent.getActivity(
                context, 60001, newTaskIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quick_add_button, newTaskPending)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
