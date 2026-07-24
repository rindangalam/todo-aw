package com.todoaw.todoaw

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class TodoawListWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val pendingCount = widgetData.getString("pendingCount", "0")
        val completedCount = widgetData.getString("completedCount", "0")

        val taskListJson = widgetData.getString("taskList", "[]")
        val taskList = mutableListOf<String>()
        try {
            val arr = JSONArray(taskListJson)
            for (i in 0 until arr.length()) {
                taskList.add(arr.getString(i))
            }
        } catch (_: Exception) {}

        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val views = RemoteViews(context.packageName, R.layout.widget_list)

        if (taskList.isEmpty()) {
            views.setViewVisibility(R.id.widget_task_container, android.view.View.GONE)
            views.setViewVisibility(R.id.widget_list_empty, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_task_container, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.widget_list_empty, android.view.View.GONE)

            val taskIds = listOf(
                R.id.widget_task_1, R.id.widget_task_2, R.id.widget_task_3,
                R.id.widget_task_4, R.id.widget_task_5
            )

            for (i in taskIds.indices) {
                if (i < taskList.size) {
                    views.setTextViewText(taskIds[i], "\u2022 ${taskList[i]}")
                    views.setViewVisibility(taskIds[i], android.view.View.VISIBLE)
                } else {
                    views.setViewVisibility(taskIds[i], android.view.View.GONE)
                }
            }
        }

        views.setOnClickPendingIntent(R.id.widget_list_title, pendingIntent)

        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
