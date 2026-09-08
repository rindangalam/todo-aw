package com.todoaw.todoaw

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class TodayWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_today)

            val accentColor = WidgetUtils.parseColor(widgetData.getString("accentColor", null), 0xFF3B82F6)
            val textColor = WidgetUtils.parseColor(widgetData.getString("textColor", null), 0xFFFFFFFF)

            val taskListJson = widgetData.getString("taskList", null) ?: "[]"
            val taskUuidsJson = widgetData.getString("taskUuids", null) ?: "[]"
            val taskTimesJson = widgetData.getString("taskTimes", null) ?: "[]"
            val completedCount = widgetData.getString("completedCount", null)?.toIntOrNull() ?: 0
            val totalCount = widgetData.getString("totalCount", null)?.toIntOrNull() ?: 0
            val progress = widgetData.getString("progress", null)?.toIntOrNull() ?: 0

            val taskTitles = try { JSONArray(taskListJson) } catch (_: Exception) { JSONArray() }
            val taskUuids = try { JSONArray(taskUuidsJson) } catch (_: Exception) { JSONArray() }
            val taskTimes = try { JSONArray(taskTimesJson) } catch (_: Exception) { JSONArray() }

            // Header: "todoaw" logo
            views.setTextViewText(R.id.widget_today_logo, "todoaw")
            views.setTextColor(R.id.widget_today_logo, textColor)
            val logoIntent = Intent(context, MainActivity::class.java).apply {
                action = "open_home"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val logoPending = PendingIntent.getActivity(
                context, 40000, logoIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_today_logo, logoPending)

            // Date text
            val dateFormat = SimpleDateFormat("EEE, d MMM", Locale.getDefault())
            views.setTextViewText(R.id.widget_today_date, dateFormat.format(Date()))
            views.setTextColor(R.id.widget_today_date, WidgetUtils.parseColor(null, 0xFF94A3B8))

            // Progress bar
            views.setInt(R.id.widget_today_progress, "setMax", 100)
            views.setInt(R.id.widget_today_progress, "setProgress", progress)

            // Progress text
            views.setTextViewText(R.id.widget_today_progress_text, "$completedCount/$totalCount selesai")
            views.setTextColor(R.id.widget_today_progress_text, WidgetUtils.parseColor(null, 0xFF94A3B8))

            // Task list container
            val taskCount = minOf(taskTitles.length(), 5)
            val taskRowIds = listOf(
                R.id.widget_today_task_row_1,
                R.id.widget_today_task_row_2,
                R.id.widget_today_task_row_3,
                R.id.widget_today_task_row_4,
                R.id.widget_today_task_row_5
            )
            val checkboxIds = listOf(
                R.id.widget_today_checkbox_1,
                R.id.widget_today_checkbox_2,
                R.id.widget_today_checkbox_3,
                R.id.widget_today_checkbox_4,
                R.id.widget_today_checkbox_5
            )
            val titleIds = listOf(
                R.id.widget_today_title_1,
                R.id.widget_today_title_2,
                R.id.widget_today_title_3,
                R.id.widget_today_title_4,
                R.id.widget_today_title_5
            )
            val timeIds = listOf(
                R.id.widget_today_time_1,
                R.id.widget_today_time_2,
                R.id.widget_today_time_3,
                R.id.widget_today_time_4,
                R.id.widget_today_time_5
            )

            for (i in 0 until 5) {
                if (i < taskCount) {
                    views.setViewVisibility(taskRowIds[i], View.VISIBLE)

                    val title = taskTitles.optString(i, "")
                    val uuid = taskUuids.optString(i, "")
                    val time = taskTimes.optString(i, "")

                    views.setTextViewText(titleIds[i], title)
                    views.setTextColor(titleIds[i], textColor)
                    views.setTextViewText(timeIds[i], time)
                    views.setTextColor(timeIds[i], WidgetUtils.parseColor(null, 0xFF94A3B8))

                    // Checkbox uses unicode since we may not have drawable resources
                    views.setTextViewText(checkboxIds[i], "○")
                    views.setTextColor(checkboxIds[i], WidgetUtils.parseColor(null, 0xFF94A3B8))

                    val taskIntent = Intent(context, MainActivity::class.java).apply {
                        action = "edit_task"
                        putExtra("task_uuid", uuid)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val taskPending = PendingIntent.getActivity(
                        context, 40001 + i, taskIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(taskRowIds[i], taskPending)
                } else {
                    views.setViewVisibility(taskRowIds[i], View.GONE)
                }
            }

            // Empty state
            if (taskCount == 0) {
                views.setViewVisibility(R.id.widget_today_empty, View.VISIBLE)
                views.setTextViewText(R.id.widget_today_empty, "Semua selesai!")
                views.setTextColor(R.id.widget_today_empty, WidgetUtils.parseColor(null, 0xFF94A3B8))
            } else {
                views.setViewVisibility(R.id.widget_today_empty, View.GONE)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
