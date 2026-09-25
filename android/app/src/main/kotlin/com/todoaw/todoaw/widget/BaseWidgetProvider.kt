package com.todoaw.todoaw.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
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
            } catch (e: Exception) {
                android.util.Log.e("WidgetDebug", "$javaClass.simpleName render failed id=$id", e)
                try {
                    val fallback = RemoteViews(context.packageName, layoutRes)
                    applySafeEmpty(context, fallback, widgetData)
                    appWidgetManager.updateAppWidget(id, fallback)
                } catch (e2: Exception) {
                    android.util.Log.e("WidgetDebug", "$javaClass.simpleName fallback failed id=$id", e2)
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
        action: String,
        extras: Map<String, String> = emptyMap(),
    ): PendingIntent {
        // home_widget 0.10 forwards clicks as intent.data URI, so encode the
        // action + extras into the URI (PendingIntent identity = data URI).
        val uri = Uri.Builder()
            .scheme("todoaw")
            .authority("widget")
            .appendPath(action)
            .apply { extras.forEach { (k, v) -> appendQueryParameter(k, v) } }
            .build()
        return HomeWidgetLaunchIntent.getActivity(
            context,
            com.todoaw.todoaw.MainActivity::class.java,
            uri,
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
