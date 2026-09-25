package com.todoaw.todoaw.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

abstract class BaseWidgetProvider : HomeWidgetProvider() {
    protected abstract val layoutRes: Int

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, layoutRes)
                render(context, views, widgetData, id)
                appWidgetManager.updateAppWidget(id, views)
            } catch (_: Exception) {
                try {
                    val fallback = RemoteViews(context.packageName, layoutRes)
                    applySafeEmpty(context, fallback, widgetData)
                    appWidgetManager.updateAppWidget(id, fallback)
                } catch (_: Exception) {
                }
            }
        }
    }

    protected abstract fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    )

    protected open fun applySafeEmpty(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
    ) {
        // Best-effort: subclasses tint their own root background.
    }

    protected fun activityPending(
        context: Context,
        requestCode: Int,
        action: String,
        extras: Map<String, String> = emptyMap(),
    ): PendingIntent {
        val intent = Intent(context, com.todoaw.todoaw.MainActivity::class.java).apply {
            this.action = action
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    protected fun activityPendingClass(
        context: Context,
        requestCode: Int,
        target: Class<*>,
        action: String,
        extras: Map<String, String> = emptyMap(),
    ): PendingIntent {
        val intent = Intent(context, target).apply {
            this.action = action
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            extras.forEach { (k, v) -> putExtra(k, v) }
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    protected fun togglePending(
        context: Context,
        requestCode: Int,
        taskUuid: String,
    ): PendingIntent {
        val intent = Intent(context, WidgetActionReceiver::class.java).apply {
            action = WidgetActionsNative.ACTION_TOGGLE_TASK
            putExtra("uuid", taskUuid)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
